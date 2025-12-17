classdef FileReader < handle
    %FILEREADER Reads PMU data files (.txt or .dat) and creates DataModel
    %   This class replaces the global variable-based leitura.m script
    %   with a clean, object-oriented approach.
    %
    %   Usage:
    %       reader = FileReader();
    %       dataModel = reader.readFromDirectory(dataDirectory, queryName, rootDirectory);
    
    properties (Access = private)
        rootDirectory = '';
        dataDirectory = '';
        queryName = '';
        timeLabel = 'Time (s)';
    end
    
    methods
        function obj = FileReader()
            %FILEREADER Constructor
        end
        
        function dataModel = readFromDirectory(obj, dataDirectory, queryName, rootDirectory)
            %READFROMDIRECTORY Read all data files from directory
            %   dataDirectory - Directory containing .txt or .dat files
            %   queryName - Name for the query/result
            %   rootDirectory - Root directory of the project
            %   Returns: DataModel instance with loaded data
            
            obj.dataDirectory = dataDirectory;
            obj.queryName = queryName;
            obj.rootDirectory = rootDirectory;
            
            % Create DataModel instance
            dataModel = src.core.DataModel();
            dataModel.rootDirectory = rootDirectory;
            dataModel.dataDirectory = dataDirectory;
            dataModel.queryName = queryName;
            dataModel.systemName = 'MedFasee Project';
            
            % Change to data directory
            originalDir = pwd;
            try
                cd(dataDirectory);
                
                % Find data files
                txtFiles = dir('*.txt');
                datFiles = dir('*.dat');
                
                if isempty(txtFiles) && isempty(datFiles)
                    error('FileReader:NoFiles', 'No .txt or .dat files found in directory: %s', dataDirectory);
                end
                
                % Determine file type
                if ~isempty(txtFiles)
                    fileType = 0; % Modern format
                    dataFiles = txtFiles;
                else
                    fileType = 1; % Legacy format
                    dataFiles = datFiles;
                end
                
                % Filter invalid files
                dataFiles = obj.filterValidFiles(dataFiles);
                
                if isempty(dataFiles)
                    error('FileReader:NoValidFiles', 'No valid data files found after filtering');
                end
                
                dataModel.terminalCount = length(dataFiles);
                
                % Read files based on type
                if fileType == 0
                    obj.readModernFormatFiles(dataFiles, dataModel);
                else
                    obj.readLegacyFormatFiles(dataFiles, dataModel);
                end
                
                % Calculate symmetrical components
                obj.calculateSymmetricalComponents(dataModel);
                
                % Prepare time label
                obj.prepareTimeLabel(dataModel);
                
                % Save to .mat file
                obj.saveToMatFile(dataModel);
                
            catch ME
                cd(originalDir);
                rethrow(ME);
            end
            
            cd(originalDir);
        end
    end
    
    methods (Access = private)
        function validFiles = filterValidFiles(obj, files)
            %FILTERVALIDFILES Filter out invalid files like log.txt, readme.txt
            validFiles = [];
            invalidNames = {'log.txt', 'readme.txt', 'log.dat', 'readme.dat'};
            
            for k = 1:length(files)
                fileName = files(k).name;
                isValid = true;
                for j = 1:length(invalidNames)
                    if strcmpi(fileName, invalidNames{j})
                        isValid = false;
                        break;
                    end
                end
                if isValid
                    validFiles = [validFiles; files(k)];
                end
            end
        end
        
        function readModernFormatFiles(obj, files, dataModel)
            %READMODERNFORMATFILES Read modern .txt format files
            terminalNames = {};
            baseVoltages = [];
            samplingRate = [];
            hasCurrent = [];
            hasFrequency = false;
            
            % First pass: read headers to determine structure
            for i = 1:length(files)
                [terminalName, baseVoltage, socInit, socEnd, rate, hasCurr, hasFreq] = ...
                    obj.readFileHeader(files(i).name);
                
                if isempty(terminalName)
                    continue; % Skip invalid file
                end
                
                terminalNames{i} = terminalName;
                baseVoltages(i) = baseVoltage;
                hasCurrent(i) = hasCurr;
                
                if i == 1
                    samplingRate = rate;
                    hasFrequency = hasFreq;
                    dataSize = round((socEnd - socInit) * rate);
                end
            end
            
            % Initialize data arrays
            dataModel.terminalNames = terminalNames;
            dataModel.baseVoltage = baseVoltages;
            dataModel.samplingRate = samplingRate;
            dataModel.hasCurrent = any(hasCurrent);
            
            % Pre-allocate data arrays
            dataModel.terminalData = zeros(dataModel.terminalCount, dataSize, 14);
            if hasFrequency
                dataModel.frequencyData = zeros(dataModel.terminalCount, dataSize);
            end
            
            % Second pass: read actual data
            for i = 1:length(files)
                fprintf('Reading file %s\n', files(i).name);
                tic
                
                obj.readFileData(files(i).name, i, dataModel, hasCurrent(i), hasFrequency);
                
                toc
            end
            
            % Replace underscores with dashes in terminal names
            for i = 1:length(dataModel.terminalNames)
                dataModel.terminalNames{i} = strrep(dataModel.terminalNames{i}, '_', '-');
            end
        end
        
        function [terminalName, baseVoltage, socInit, socEnd, samplingRate, hasCurrent, hasFrequency] = readFileHeader(obj, fileName)
            %READFILEHEADER Read header information from file
            terminalName = '';
            baseVoltage = [];
            socInit = [];
            socEnd = [];
            samplingRate = [];
            hasCurrent = false;
            hasFrequency = false;
            
            fileID = fopen(fileName, 'rt');
            if fileID <= 0
                return;
            end
            
            try
                % Read "Terminal:"
                fscanf(fileID, '%s', 1);
                
                % Read terminal name
                terminalName = fscanf(fileID, '%s', 1);
                if isempty(terminalName)
                    fclose(fileID);
                    return;
                end
                
                % Read "Tensão base:"
                fscanf(fileID, '%s', 1); % "Tensão"
                fscanf(fileID, '%s', 1); % "base:"
                
                % Read base voltage value
                baseVoltageStr = fscanf(fileID, '%s', 1);
                if isempty(baseVoltageStr)
                    fclose(fileID);
                    return;
                end
                baseVoltageStr = strrep(baseVoltageStr, ',', '.');
                baseVoltage = str2double(baseVoltageStr);
                if isnan(baseVoltage)
                    fclose(fileID);
                    return;
                end
                
                % Read "kV"
                fscanf(fileID, '%s', 1);
                
                % Read "SOC inicial:"
                fscanf(fileID, '%s', 1); % "SOC"
                fscanf(fileID, '%s', 1); % "inicial:"
                
                % Read SOC initial value
                socInitStr = fscanf(fileID, '%s', 1);
                if isempty(socInitStr)
                    fclose(fileID);
                    return;
                end
                socInitStr = strrep(socInitStr, ',', '.');
                socInit = str2double(socInitStr);
                if isnan(socInit)
                    fclose(fileID);
                    return;
                end
                
                % Read "SOC final:"
                fscanf(fileID, '%s', 1); % "SOC"
                fscanf(fileID, '%s', 1); % "final:"
                
                % Read SOC final value
                socEndStr = fscanf(fileID, '%s', 1);
                if isempty(socEndStr)
                    fclose(fileID);
                    return;
                end
                socEndStr = strrep(socEndStr, ',', '.');
                socEnd = str2double(socEndStr);
                if isnan(socEnd)
                    fclose(fileID);
                    return;
                end
                
                % Read "Taxa:"
                fscanf(fileID, '%s', 1);
                
                % Read sampling rate
                rateStr = fscanf(fileID, '%s', 1);
                if isempty(rateStr)
                    fclose(fileID);
                    return;
                end
                rateStr = strrep(rateStr, ',', '.');
                samplingRate = str2double(rateStr);
                if isnan(samplingRate)
                    fclose(fileID);
                    return;
                end
                
                % Read "fasores/s"
                fscanf(fileID, '%s', 1);
                
                % Skip "Total de frames faltantes: X"
                fscanf(fileID, '%s', 1); % "Total"
                fscanf(fileID, '%s', 1); % "de"
                fscanf(fileID, '%s', 1); % "frames"
                fscanf(fileID, '%s', 1); % "faltantes:"
                fscanf(fileID, '%s', 1); % value
                
                % Read column headers
                fscanf(fileID, '%s', 1); % "Tempo_(SOC)"
                fscanf(fileID, '%s', 1); % "VA_mod_(V)"
                fscanf(fileID, '%s', 1); % "VA_ang_(graus)"
                fscanf(fileID, '%s', 1); % "VB_mod_(V)"
                fscanf(fileID, '%s', 1); % "VB_ang_(graus)"
                fscanf(fileID, '%s', 1); % "VC_mod_(V)"
                fscanf(fileID, '%s', 1); % "VC_ang_(graus)"
                
                % Check for current or frequency
                nextField = fscanf(fileID, '%s', 1);
                if strcmp(nextField, 'IA_mod_(A)')
                    hasCurrent = true;
                    % Skip current fields
                    fscanf(fileID, '%s', 1); % "IA_ang"
                    fscanf(fileID, '%s', 1); % "IB_mod"
                    fscanf(fileID, '%s', 1); % "IB_ang"
                    fscanf(fileID, '%s', 1); % "IC_mod"
                    fscanf(fileID, '%s', 1); % "IC_ang"
                    nextField = fscanf(fileID, '%s', 1);
                end
                
                if strcmp(nextField, 'Frequência')
                    hasFrequency = true;
                    fscanf(fileID, '%s', 1); % "Delta_Freq"
                    fscanf(fileID, '%s', 1); % "Faltante"
                elseif strcmp(nextField, 'Faltante')
                    hasFrequency = false;
                end
                
            catch ME
                fclose(fileID);
                rethrow(ME);
            end
            
            fclose(fileID);
        end
        
        function readFileData(obj, fileName, terminalIndex, dataModel, hasCurr, hasFreq)
            %READFILEDATA Read actual data from file
            fileID = fopen(fileName, 'rt');
            if fileID <= 0
                error('FileReader:CannotOpen', 'Cannot open file: %s', fileName);
            end
            
            try
                % Skip header (already read)
                obj.skipFileHeader(fileID, hasCurr, hasFreq);
                
                % Read data rows
                dataSize = size(dataModel.terminalData, 2);
                skipTime = false;
                
                for row = 1:dataSize
                    % Read time
                    if ~skipTime
                        timeStr = fscanf(fileID, '%s', 1);
                        if isempty(timeStr) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 1) = str2double(timeStr);
                    end
                    
                    % Read voltages
                    val = fscanf(fileID, '%f', 1);
                    if isempty(val) || feof(fileID)
                        break;
                    end
                    dataModel.terminalData(terminalIndex, row, 2) = val; % VA_MOD
                    
                    val = fscanf(fileID, '%f', 1);
                    if isempty(val) || feof(fileID)
                        break;
                    end
                    dataModel.terminalData(terminalIndex, row, 5) = val; % VA_ANG
                    
                    val = fscanf(fileID, '%f', 1);
                    if isempty(val) || feof(fileID)
                        break;
                    end
                    dataModel.terminalData(terminalIndex, row, 3) = val; % VB_MOD
                    
                    val = fscanf(fileID, '%f', 1);
                    if isempty(val) || feof(fileID)
                        break;
                    end
                    dataModel.terminalData(terminalIndex, row, 6) = val; % VB_ANG
                    
                    val = fscanf(fileID, '%f', 1);
                    if isempty(val) || feof(fileID)
                        break;
                    end
                    dataModel.terminalData(terminalIndex, row, 4) = val; % VC_MOD
                    
                    val = fscanf(fileID, '%f', 1);
                    if isempty(val) || feof(fileID)
                        break;
                    end
                    dataModel.terminalData(terminalIndex, row, 7) = val; % VC_ANG
                    
                    % Read currents if present
                    if hasCurr
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 8) = val; % IA_MOD
                        
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 11) = val; % IA_ANG
                        
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 9) = val; % IB_MOD
                        
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 12) = val; % IB_ANG
                        
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 10) = val; % IC_MOD
                        
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.terminalData(terminalIndex, row, 13) = val; % IC_ANG
                    end
                    
                    % Read frequency if present
                    if hasFreq
                        val = fscanf(fileID, '%f', 1);
                        if isempty(val) || feof(fileID)
                            break;
                        end
                        dataModel.frequencyData(terminalIndex, row) = val;
                        
                        % Skip Delta_Freq
                        fscanf(fileID, '%f', 1);
                    end
                    
                    % Read missing flag
                    missingFlag = fscanf(fileID, '%s', 1);
                    if isempty(missingFlag) || feof(fileID)
                        break;
                    end
                    
                    if strcmp(missingFlag, '*')
                        dataModel.terminalData(terminalIndex, row, 14) = 1;
                        skipTime = false;
                    else
                        dataModel.terminalData(terminalIndex, row, 14) = 0;
                        skipTime = true;
                    end
                end
                
            catch ME
                fclose(fileID);
                rethrow(ME);
            end
            
            fclose(fileID);
        end
        
        function skipFileHeader(obj, fileID, hasCurr, hasFreq)
            %SKIPFILEHEADER Skip header lines in file
            % Skip to data section
            for i = 1:20 % Skip header lines
                line = fgetl(fileID);
                if ~ischar(line)
                    break;
                end
                if contains(line, 'Tempo_(SOC)') || contains(line, 'VA_mod')
                    break;
                end
            end
        end
        
        function readLegacyFormatFiles(obj, files, dataModel)
            %READLEGACYFORMATFILES Read legacy .dat format files
            % This is a simplified version - full implementation would
            % require reading terminais.cfg file
            error('FileReader:LegacyNotImplemented', 'Legacy format reading not yet fully implemented');
        end
        
        function calculateSymmetricalComponents(obj, dataModel)
            %CALCULATESYMMETRICALCOMPONENTS Calculate positive, negative, zero sequence
            fprintf('Calculating symmetrical components\n');
            tic
            
            terminalCount = dataModel.terminalCount;
            dataSize = size(dataModel.terminalData, 2);
            
            % Initialize arrays
            dataModel.terminalDataSp = zeros(terminalCount, dataSize, 5);
            dataModel.terminalDataSn = zeros(terminalCount, dataSize, 4);
            dataModel.terminalDataS0 = zeros(terminalCount, dataSize, 4);
            
            % Conversion constants
            angleConv = 2*pi/360; % degrees to radians
            def3f = 2*pi/3; % 120 degrees
            a = cos(def3f) + 1i * sin(def3f); % operator "a"
            aa = a^2;
            
            % Calculate for each terminal
            for i = 1:terminalCount
                for ii = 1:dataSize
                    % Voltage symmetrical components
                    va = dataModel.terminalData(i, ii, 2) * exp(1i * dataModel.terminalData(i, ii, 5) * angleConv);
                    vb = dataModel.terminalData(i, ii, 3) * exp(1i * dataModel.terminalData(i, ii, 6) * angleConv);
                    vc = dataModel.terminalData(i, ii, 4) * exp(1i * dataModel.terminalData(i, ii, 7) * angleConv);
                    
                    fasor_sp = (va + vb * a + vc * aa) / 3;
                    fasor_sn = (va + vb * aa + vc * a) / 3;
                    fasor_s0 = (va + vb + vc) / 3;
                    
                    dataModel.terminalDataSp(i, ii, 1) = abs(fasor_sp);
                    dataModel.terminalDataSp(i, ii, 2) = angle(fasor_sp) / angleConv;
                    
                    dataModel.terminalDataSn(i, ii, 1) = abs(fasor_sn);
                    dataModel.terminalDataSn(i, ii, 2) = angle(fasor_sn) / angleConv;
                    
                    dataModel.terminalDataS0(i, ii, 1) = abs(fasor_s0);
                    dataModel.terminalDataS0(i, ii, 2) = angle(fasor_s0) / angleConv;
                    
                    % Current symmetrical components if available
                    if dataModel.hasCurrent
                        ia = dataModel.terminalData(i, ii, 8) * exp(1i * dataModel.terminalData(i, ii, 11) * angleConv);
                        ib = dataModel.terminalData(i, ii, 9) * exp(1i * dataModel.terminalData(i, ii, 12) * angleConv);
                        ic = dataModel.terminalData(i, ii, 10) * exp(1i * dataModel.terminalData(i, ii, 13) * angleConv);
                        
                        fasor_sp = (ia + ib * a + ic * aa) / 3;
                        fasor_sn = (ia + ib * aa + ic * a) / 3;
                        fasor_s0 = (ia + ib + ic) / 3;
                        
                        dataModel.terminalDataSp(i, ii, 3) = abs(fasor_sp);
                        dataModel.terminalDataSp(i, ii, 4) = angle(fasor_sp) / angleConv;
                        
                        dataModel.terminalDataSn(i, ii, 3) = abs(fasor_sn);
                        dataModel.terminalDataSn(i, ii, 4) = angle(fasor_sn) / angleConv;
                        
                        dataModel.terminalDataS0(i, ii, 3) = abs(fasor_s0);
                        dataModel.terminalDataS0(i, ii, 4) = angle(fasor_s0) / angleConv;
                    end
                    
                    % Calculate frequency from positive sequence
                    if ii > 1
                        if dataModel.terminalData(i, ii, 14) || dataModel.terminalData(i, ii-1, 14)
                            dataModel.terminalDataSp(i, ii, 5) = dataModel.terminalDataSp(i, ii-1, 5);
                        else
                            diffAngle = dataModel.terminalDataSp(i, ii, 2) - dataModel.terminalDataSp(i, ii-1, 2);
                            if diffAngle > 180.0
                                diffAngle = diffAngle - 360;
                            elseif diffAngle < -180.0
                                diffAngle = diffAngle + 360;
                            end
                            dataModel.terminalDataSp(i, ii, 5) = 60.0 + diffAngle * dataModel.samplingRate / 360;
                        end
                    end
                end
                
                % Set first frequency point equal to second
                if dataSize > 1
                    dataModel.terminalDataSp(i, 1, 5) = dataModel.terminalDataSp(i, 2, 5);
                end
            end
            
            toc
        end
        
        function prepareTimeLabel(obj, dataModel)
            %PREPARETIMELABEL Prepare time label from first timestamp
            if isempty(dataModel.terminalData)
                return;
            end
            
            time1 = dataModel.terminalData(1, 1, 1) - 0 * 3600; % UTC time
            
            % Validate time
            if isnan(time1) || isinf(time1) || time1 <= 0
                dataModel.timeLabel = 'Time (s)';
                return;
            end
            
            % Convert to date
            dateNum = time1/86400 + datenum(1970, 1, 1, 0, 0, 0);
            dateMin = datenum(1900, 1, 1, 0, 0, 0);
            dateMax = datenum(2100, 12, 31, 23, 59, 59);
            
            if dateNum < dateMin || dateNum > dateMax || isnan(dateNum) || isinf(dateNum)
                dataModel.timeLabel = 'Time (s)';
                return;
            end
            
            try
                dateStr = datestr(dateNum, 'dd-mmm-yyyy HH:MM:SS');
                
                % Convert month abbreviation
                monthMap = containers.Map({'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', ...
                    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'}, ...
                    {'01', '02', '03', '04', '05', '06', ...
                    '07', '08', '09', '10', '11', '12'});
                
                monthAbbr = dateStr(4:6);
                if isKey(monthMap, monthAbbr)
                    month = monthMap(monthAbbr);
                else
                    month = '01';
                end
                
                if length(dateStr) == 11
                    dataModel.timeLabel = sprintf('Time(s) - Start: %s/%s/%s 00:00:00 (UTC)', ...
                        dateStr(1:2), month, dateStr(8:11));
                else
                    dataModel.timeLabel = sprintf('Time(s) - Start: %s/%s/%s (UTC)', ...
                        dateStr(1:2), month, dateStr(8:20));
                end
            catch
                dataModel.timeLabel = 'Time (s)';
            end
        end
        
        function saveToMatFile(obj, dataModel)
            %SAVETOMATFILE Save DataModel to .mat file with legacy variable names
            fprintf('Saving MATLAB data file...\n');
            
            queriesDir = fullfile(obj.rootDirectory, 'consultas');
            if ~exist(queriesDir, 'dir')
                mkdir(queriesDir);
            end
            
            fileName = fullfile(queriesDir, [obj.queryName, '.mat']);
            
            % Map to legacy variable names for backward compatibility
            SPMS_nome = dataModel.systemName;
            terminais_qtde = dataModel.terminalCount;
            base_modulo = dataModel.baseVoltage;
            
            % Convert terminalNames to char array
            if iscell(dataModel.terminalNames)
                terminal_nome = char(dataModel.terminalNames);
            else
                terminal_nome = dataModel.terminalNames;
            end
            
            terminais_dados = dataModel.terminalData;
            terminais_dados_sp = dataModel.terminalDataSp;
            terminais_dados_sn = dataModel.terminalDataSn;
            terminais_dados_s0 = dataModel.terminalDataS0;
            tempo_legenda = dataModel.timeLabel;
            tem_corrente = dataModel.hasCurrent;
            taxa_amos = dataModel.samplingRate;
            
            % Save with or without frequency data
            if ~isempty(dataModel.frequencyData)
                terminais_frequencia = dataModel.frequencyData;
                save(fileName, 'SPMS_nome', 'terminais_qtde', 'base_modulo', ...
                    'terminal_nome', 'terminais_dados', 'terminais_dados_sp', ...
                    'terminais_dados_sn', 'terminais_dados_s0', 'tempo_legenda', ...
                    'tem_corrente', 'taxa_amos', 'terminais_frequencia', '-v7.3');
            else
                save(fileName, 'SPMS_nome', 'terminais_qtde', 'base_modulo', ...
                    'terminal_nome', 'terminais_dados', 'terminais_dados_sp', ...
                    'terminais_dados_sn', 'terminais_dados_s0', 'tempo_legenda', ...
                    'tem_corrente', 'taxa_amos', '-v7.3');
            end
            
            if ~exist(fileName, 'file')
                error('FileReader:SaveFailed', 'Failed to create file: %s', fileName);
            end
            
            fprintf('COMPLETED! File saved to: %s\n', fileName);
        end
    end
end



