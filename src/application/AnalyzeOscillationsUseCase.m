classdef AnalyzeOscillationsUseCase < handle
    %ANALYZEOSCILLATIONSUSECASE Use case for oscillation analysis
    %   Orchestrates RBE, Prony, or Matrix Pencil analysis
    
    properties (Access = private)
        analysisService = [];
    end
    
    methods
        function obj = AnalyzeOscillationsUseCase(analysisService)
            %ANALYZEOSCILLATIONSUSECASE Constructor
            %   analysisService - IOscillationAnalysisService implementation
            obj.analysisService = analysisService;
        end
        
        function result = execute(obj, query, selectedPMUIndices, signalType, parameters)
            %EXECUTE Execute oscillation analysis
            %   query - Query domain object
            %   selectedPMUIndices - Array of PMU indices to analyze
            %   signalType - 'frequency', 'voltage', 'current', etc.
            %   parameters - Analysis parameters structure
            %   Returns: Analysis result structure
            
            if isempty(selectedPMUIndices)
                error('AnalyzeOscillationsUseCase:NoSelection', 'No PMUs selected');
            end
            
            % Get selected PMUs
            selectedPMUs = query.getSelectedPMUs();
            if length(selectedPMUs) ~= length(selectedPMUIndices)
                query.setSelection(selectedPMUIndices);
                selectedPMUs = query.getSelectedPMUs();
            end
            
            % Extract signal data based on type
            signal = obj.extractSignal(selectedPMUs, signalType);
            
            % Add sampling rate to parameters if not present
            if ~isfield(parameters, 'samplingRate')
                parameters.samplingRate = query.samplingRate;
            end
            
            % Perform analysis
            result = obj.analysisService.analyze(signal, parameters);
        end
        
        function signal = extractSignal(obj, pmus, signalType)
            %EXTRACTSIGNAL Extract signal data from PMUs
            numPMUs = length(pmus);
            signal = [];
            
            for i = 1:numPMUs
                pmu = pmus{i};
                
                switch lower(signalType)
                    case 'frequency'
                        data = pmu.getFrequencyData();
                    case 'voltage'
                        voltageData = pmu.getVoltageData();
                        % Extract positive sequence magnitude (column 1 from symmetrical components)
                        data = voltageData(:, 2); % VA_MOD as example
                    case 'current'
                        if pmu.hasCurrent
                            currentData = pmu.getCurrentData();
                            data = currentData(:, 1); % IA_MOD
                        else
                            error('AnalyzeOscillationsUseCase:NoCurrent', ...
                                'PMU %d does not have current data', i);
                        end
                    otherwise
                        error('AnalyzeOscillationsUseCase:UnknownSignalType', ...
                            'Unknown signal type: %s', signalType);
                end
                
                if isempty(signal)
                    signal = zeros(numPMUs, length(data));
                end
                signal(i, :) = data';
            end
        end
    end
end



