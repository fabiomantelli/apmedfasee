classdef DataModel < handle
    %DATAMODEL Central data model class replacing global variables
    %   This class encapsulates all PMU data and system state, eliminating
    %   the need for global variables throughout the codebase.
    %
    %   Properties:
    %       systemName - System/query name
    %       baseVoltage - Base voltage matrix (kV)
    %       samplingRate - Sampling rate (samples/second)
    %       timeLabel - Time axis label string
    %       terminalData - Main terminal data array [terminals x samples x 14]
    %       terminalDataS0 - Zero sequence data [terminals x samples x 4]
    %       terminalDataSn - Negative sequence data [terminals x samples x 4]
    %       terminalDataSp - Positive sequence data [terminals x samples x 5]
    %       terminalCount - Number of terminals/PMUs
    %       terminalNames - Terminal/PMU names (char array or cell array)
    %       frequencyData - Frequency data [terminals x samples]
    %       timeVector - Time vector for plotting
    %       timeFactor - Time scaling factor
    %       hasCurrent - Boolean indicating if current data is available
    %       selection - Binary selection vector [1 x terminals]
    %       referenceIndex - Index of reference terminal
    %       terminalColors - Color table for terminals
    %       plotSelection - Selected plot/graphic index
    %       plotName - Selected plot/graphic name
    %       signalData - Signal data for plotting
    %       signalName - Signal name
    %       signalUnit - Signal unit
    %       signalLegend - Signal legend
    %       plotDrawn - Flag indicating if plot was drawn
    %       rootDirectory - Root directory path
    %       dataDirectory - Data directory path
    %       queryName - Query/result name
    %       methodSelection - Selected analysis method index
    %       methodName - Selected analysis method name
    
    properties
        % System information
        systemName = '';              % SPMS_nome
        baseVoltage = [];             % base_modulo
        samplingRate = [];            % taxa_amos
        timeLabel = 'Time (s)';       % tempo_legenda
        
        % Terminal data arrays
        terminalData = [];             % terminais_dados [N x M x 14]
        terminalDataS0 = [];          % terminais_dados_s0 [N x M x 4]
        terminalDataSn = [];          % terminais_dados_sn [N x M x 4]
        terminalDataSp = [];          % terminais_dados_sp [N x M x 5]
        frequencyData = [];           % terminais_frequencia [N x M]
        
        % Terminal metadata
        terminalCount = 0;             % terminais_qtde
        terminalNames = {};            % terminal_nome (converted to cell)
        hasCurrent = false;            % tem_corrente
        
        % Time data
        timeVector = [];               % tempo
        timeFactor = 1;                % fator_tempo
        
        % Selection and reference
        selection = [];                % selecao [1 x N]
        referenceIndex = 1;            % ref_sel
        
        % Plotting
        plotSelection = [];            % aux_graf
        plotName = '';                 % graf_sel
        signalData = [];               % sinal
        signalName = '';               % sinal_nome
        signalUnit = '';               % unidade
        signalLegend = {};             % legenda
        plotDrawn = false;             % tracou
        
        % Analysis methods
        methodSelection = [];          % aux_met
        methodName = '';               % met_sel
        
        % Directories
        rootDirectory = '';             % dir_raiz
        dataDirectory = '';            % dir_dat
        queryName = '';                % ArmazenaResult
        
        % Colors
        terminalColors = [];            % terminais_cor
    end
    
    methods
        function obj = DataModel()
            %DATAMODEL Constructor
            %   Creates a new DataModel instance with default values
            obj.initializeDefaultColors();
        end
        
        function loadFromFile(obj, filePath)
            %LOADFROMFILE Load data from .mat file
            %   filePath - Full path to .mat file
            %   Loads all variables from the .mat file and maps them to
            %   DataModel properties
            
            if ~exist(filePath, 'file')
                error('DataModel:FileNotFound', 'File not found: %s', filePath);
            end
            
            try
                % Load all variables from file
                loadedData = load(filePath);
                
                % Map loaded variables to properties
                if isfield(loadedData, 'SPMS_nome')
                    obj.systemName = loadedData.SPMS_nome;
                end
                
                if isfield(loadedData, 'base_modulo')
                    obj.baseVoltage = loadedData.base_modulo;
                end
                
                if isfield(loadedData, 'taxa_amos')
                    obj.samplingRate = loadedData.taxa_amos;
                end
                
                if isfield(loadedData, 'tempo_legenda')
                    obj.timeLabel = loadedData.tempo_legenda;
                end
                
                if isfield(loadedData, 'terminais_dados')
                    obj.terminalData = loadedData.terminais_dados;
                end
                
                if isfield(loadedData, 'terminais_dados_s0')
                    obj.terminalDataS0 = loadedData.terminais_dados_s0;
                end
                
                if isfield(loadedData, 'terminais_dados_sn')
                    obj.terminalDataSn = loadedData.terminais_dados_sn;
                end
                
                if isfield(loadedData, 'terminais_dados_sp')
                    obj.terminalDataSp = loadedData.terminais_dados_sp;
                end
                
                if isfield(loadedData, 'terminais_frequencia')
                    obj.frequencyData = loadedData.terminais_frequencia;
                end
                
                if isfield(loadedData, 'terminais_qtde')
                    obj.terminalCount = loadedData.terminais_qtde;
                end
                
                if isfield(loadedData, 'terminal_nome')
                    % Convert char array to cell array if needed
                    terminal_nome = loadedData.terminal_nome;
                    if ischar(terminal_nome)
                        obj.terminalNames = cellstr(terminal_nome);
                    elseif iscell(terminal_nome)
                        obj.terminalNames = terminal_nome;
                    else
                        obj.terminalNames = {};
                    end
                end
                
                if isfield(loadedData, 'tem_corrente')
                    obj.hasCurrent = loadedData.tem_corrente;
                end
                
                % Initialize selection vector
                if obj.terminalCount > 0
                    obj.selection = zeros(1, obj.terminalCount);
                end
                
                % Initialize reference index
                obj.referenceIndex = 1;
                
                % Prepare time vector
                obj.prepareTimeVector();
                
            catch ME
                error('DataModel:LoadError', 'Error loading file: %s', ME.message);
            end
        end
        
        function saveToFile(obj, filePath)
            %SAVETOFILE Save data to .mat file
            %   filePath - Full path to .mat file
            %   Saves all DataModel properties to .mat file using legacy
            %   variable names for backward compatibility
            
            try
                % Map properties to legacy variable names
                SPMS_nome = obj.systemName;
                base_modulo = obj.baseVoltage;
                taxa_amos = obj.samplingRate;
                tempo_legenda = obj.timeLabel;
                terminais_dados = obj.terminalData;
                terminais_dados_s0 = obj.terminalDataS0;
                terminais_dados_sn = obj.terminalDataSn;
                terminais_dados_sp = obj.terminalDataSp;
                terminais_frequencia = obj.frequencyData;
                terminais_qtde = obj.terminalCount;
                
                % Convert terminalNames back to char array if needed
                if iscell(obj.terminalNames)
                    terminal_nome = char(obj.terminalNames);
                else
                    terminal_nome = obj.terminalNames;
                end
                
                tem_corrente = obj.hasCurrent;
                
                % Save to file
                save(filePath, 'SPMS_nome', 'base_modulo', 'taxa_amos', ...
                    'tempo_legenda', 'terminais_dados', 'terminais_dados_s0', ...
                    'terminais_dados_sn', 'terminais_dados_sp', ...
                    'terminais_frequencia', 'terminais_qtde', 'terminal_nome', ...
                    'tem_corrente', '-v7.3');
                
            catch ME
                error('DataModel:SaveError', 'Error saving file: %s', ME.message);
            end
        end
        
        function selectedPMUs = getSelectedPMUs(obj)
            %GETSELECTEDPMUS Get indices of selected PMUs
            %   Returns array of indices where selection == 1
            selectedPMUs = find(obj.selection == 1);
        end
        
        function count = getSelectedPMUCount(obj)
            %GETSELECTEDPMUCOUNT Get number of selected PMUs
            count = sum(obj.selection == 1);
        end
        
        function prepareTimeVector(obj)
            %PREPARETIMEVECTOR Prepare time vector from terminal data
            %   Extracts time from terminalData or creates synthetic time
            %   based on sampling rate
            
            if ~isempty(obj.terminalData)
                % Find minimum common size across all terminals
                sizes = zeros(1, obj.terminalCount);
                for i = 1:obj.terminalCount
                    validData = obj.terminalData(i, :, 1);
                    validData = validData(~isnan(validData) & validData ~= 0);
                    if ~isempty(validData)
                        sizes(i) = length(validData);
                    else
                        sizes(i) = size(obj.terminalData, 2);
                    end
                end
                dataSize = min(sizes(sizes > 0));
                if isempty(dataSize)
                    dataSize = size(obj.terminalData, 2);
                end
                
                if dataSize > 0
                    % Extract time from first terminal
                    timeSOC = obj.terminalData(1, 1:dataSize, 1);
                    
                    % Convert SOC (Unix timestamp) to relative time
                    if ~isempty(timeSOC) && all(timeSOC > 0) && max(timeSOC) > 1e9
                        initialTime = timeSOC(1);
                        obj.timeVector = timeSOC - initialTime;
                    else
                        obj.timeVector = timeSOC;
                    end
                    obj.timeFactor = 1;
                end
            elseif ~isempty(obj.terminalDataSp)
                % Use terminalDataSp size
                dataSize = size(obj.terminalDataSp, 2);
                if dataSize > 0
                    % Try to get time from terminalData if available
                    if ~isempty(obj.terminalData) && size(obj.terminalData, 2) >= dataSize
                        timeSOC = obj.terminalData(1, 1:dataSize, 1);
                        if ~isempty(timeSOC) && all(timeSOC > 0) && max(timeSOC) > 1e9
                            initialTime = timeSOC(1);
                            obj.timeVector = timeSOC - initialTime;
                        else
                            obj.timeVector = timeSOC;
                        end
                    else
                        % Create synthetic time based on sampling rate
                        if ~isempty(obj.samplingRate) && obj.samplingRate > 0
                            obj.timeVector = (0:(dataSize-1)) / obj.samplingRate;
                        else
                            obj.timeVector = 0:(dataSize-1);
                        end
                    end
                    obj.timeFactor = 1;
                end
            end
        end
        
        function isValid = validate(obj)
            %VALIDATE Validate data model integrity
            %   Returns true if data model has minimum required data
            isValid = false;
            
            if obj.terminalCount <= 0
                return;
            end
            
            if isempty(obj.terminalNames) || length(obj.terminalNames) ~= obj.terminalCount
                return;
            end
            
            if isempty(obj.terminalData) && isempty(obj.terminalDataSp)
                return;
            end
            
            isValid = true;
        end
        
        function clearPlotData(obj)
            %CLEARPLOTDATA Clear plotting-related data
            obj.signalData = [];
            obj.signalName = '';
            obj.signalUnit = '';
            obj.signalLegend = {};
            obj.plotDrawn = false;
        end
        
        function initializeDefaultColors(obj)
            %INITIALIZEDEFAULTCOLORS Initialize default color table
            obj.terminalColors = [
                '[1.00 0.00 1.00]'  % Magenta
                '[0.00 0.75 1.00]'  % Cyan
                '[1.00 0.50 0.00]'  % Orange
                '[1.00 0.00 0.00]'  % Red
                '[0.70 0.00 0.00]'  % Dark Red
                '[0.50 0.00 0.70]'  % Purple
                '[0.75 0.75 0.00]'  % Burnt Yellow
                '[0.00 1.00 0.00]'  % Green
                '[0.00 0.00 1.00]'  % Blue
                '[0.00 0.00 0.00]'  % Black
                '[0.75 0.00 0.75]'  % Dark Magenta
                '[0.80 0.80 0.80]'  % Gray
                '[0.85 0.70 1.00]'  % Light Purple
                '[0.00 0.80 0.00]'  % Green 80%
                '[0.00 0.40 0.00]'  % Dark Green
            ];
        end
        
        function loadColorsFromFile(obj, filePath)
            %LOADCOLORSFROMFILE Load color table from tab_cor.m
            %   filePath - Path to tab_cor.m file
            if exist(filePath, 'file')
                try
                    [fileDir, ~, ~] = fileparts(filePath);
                    addpath(fileDir);
                    tab_cor;  % This should set terminais_cor
                    rmpath(fileDir);
                    if exist('terminais_cor', 'var')
                        obj.terminalColors = terminais_cor;
                        clear terminais_cor;
                    end
                catch
                    % If loading fails, keep default colors
                end
            end
        end
    end
end



