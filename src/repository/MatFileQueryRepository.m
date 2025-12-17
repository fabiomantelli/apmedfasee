classdef MatFileQueryRepository < src.repository.IQueryRepository
    %MATFILEQUERYREPOSITORY Implementation of IQueryRepository using .mat files
    %   Handles loading and saving queries to/from .mat files
    
    properties (Access = private)
        queriesDirectory = '';
    end
    
    methods
        function obj = MatFileQueryRepository(queriesDirectory)
            %MATFILEQUERYREPOSITORY Constructor
            if nargin > 0
                obj.queriesDirectory = queriesDirectory;
            else
                obj.queriesDirectory = src.infrastructure.PathManager.getQueriesDirectory();
            end
        end
        
        function query = loadQuery(obj, queryName)
            %LOADQUERY Load query from .mat file
            filePath = fullfile(obj.queriesDirectory, [queryName, '.mat']);
            
            if ~exist(filePath, 'file')
                error('QueryRepository:FileNotFound', 'Query file not found: %s', queryName);
            end
            
            % Load legacy variables
            loadedData = load(filePath);
            
            % Convert to domain objects
            query = src.domain.Query(queryName);
            
            if isfield(loadedData, 'SPMS_nome')
                query.systemName = loadedData.SPMS_nome;
            end
            if isfield(loadedData, 'taxa_amos')
                query.samplingRate = loadedData.taxa_amos;
            end
            if isfield(loadedData, 'tempo_legenda')
                query.timeLabel = loadedData.tempo_legenda;
            end
            
            % Convert terminal_nome to cell array
            if isfield(loadedData, 'terminal_nome')
                if ischar(loadedData.terminal_nome)
                    terminalNames = cellstr(loadedData.terminal_nome);
                else
                    terminalNames = loadedData.terminal_nome;
                end
            else
                terminalNames = {};
            end
            
            % Create PMU objects
            terminalCount = loadedData.terminais_qtde;
            for i = 1:terminalCount
                pmuName = '';
                if i <= length(terminalNames)
                    pmuName = terminalNames{i};
                end
                
                baseVoltage = 0;
                if isfield(loadedData, 'base_modulo') && i <= size(loadedData.base_modulo, 1)
                    baseVoltage = loadedData.base_modulo(i, 1);
                end
                
                pmu = src.domain.PMU(i, pmuName, baseVoltage);
                
                % Set voltage data
                if isfield(loadedData, 'terminais_dados')
                    voltageData = squeeze(loadedData.terminais_dados(i, :, :));
                    pmu.setVoltageData(voltageData);
                    
                    % Extract time vector
                    if size(voltageData, 2) >= 1
                        timeVec = voltageData(:, 1);
                        pmu.setTimeVector(timeVec);
                    end
                end
                
                % Set current data if available
                if isfield(loadedData, 'tem_corrente') && loadedData.tem_corrente(i)
                    if isfield(loadedData, 'terminais_dados')
                        currentData = squeeze(loadedData.terminais_dados(i, :, 8:13));
                        pmu.setCurrentData(currentData);
                    end
                end
                
                % Set frequency data if available
                if isfield(loadedData, 'terminais_frequencia')
                    freqData = loadedData.terminais_frequencia(i, :)';
                    pmu.setFrequencyData(freqData);
                end
                
                query.addPMU(pmu);
            end
        end
        
        function saveQuery(obj, query)
            %SAVEQUERY Save query to .mat file
            filePath = fullfile(obj.queriesDirectory, [query.name, '.mat']);
            
            % Convert domain objects to legacy variables
            pmus = query.getPMUs();
            terminalCount = length(pmus);
            
            % Initialize arrays
            terminal_nome = char(pmus{1}.name);
            base_modulo = zeros(terminalCount, 1);
            terminais_dados = [];
            terminais_frequencia = [];
            tem_corrente = zeros(1, terminalCount);
            
            % Extract data from PMU objects
            for i = 1:terminalCount
                pmu = pmus{i};
                
                % Terminal name
                if i == 1
                    terminal_nome = char(pmu.name);
                else
                    terminal_nome = char(terminal_nome, pmu.name);
                end
                
                base_modulo(i) = pmu.baseVoltage;
                tem_corrente(i) = pmu.hasCurrent;
                
                % Voltage data
                voltageData = pmu.getVoltageData();
                if isempty(terminais_dados)
                    terminais_dados = zeros(terminalCount, size(voltageData, 1), 14);
                end
                terminais_dados(i, :, :) = voltageData;
                
                % Frequency data
                freqData = pmu.getFrequencyData();
                if ~isempty(freqData)
                    if isempty(terminais_frequencia)
                        terminais_frequencia = zeros(terminalCount, length(freqData));
                    end
                    terminais_frequencia(i, :) = freqData';
                end
            end
            
            % Save with legacy variable names
            SPMS_nome = query.systemName;
            taxa_amos = query.samplingRate;
            tempo_legenda = query.timeLabel;
            
            if ~isempty(terminais_frequencia)
                save(filePath, 'SPMS_nome', 'terminais_qtde', 'base_modulo', ...
                    'terminal_nome', 'terminais_dados', 'terminais_frequencia', ...
                    'tempo_legenda', 'tem_corrente', 'taxa_amos', '-v7.3');
            else
                save(filePath, 'SPMS_nome', 'terminais_qtde', 'base_modulo', ...
                    'terminal_nome', 'terminais_dados', 'tempo_legenda', ...
                    'tem_corrente', 'taxa_amos', '-v7.3');
            end
        end
        
        function queryNames = listQueries(obj)
            %LISTQUERIES List all available query names
            if ~exist(obj.queriesDirectory, 'dir')
                queryNames = {};
                return;
            end
            
            files = dir(fullfile(obj.queriesDirectory, '*.mat'));
            queryNames = cell(length(files), 1);
            for i = 1:length(files)
                [~, name, ~] = fileparts(files(i).name);
                queryNames{i} = name;
            end
        end
    end
end

