classdef AnalyzeCoherenceUseCase < handle
    %ANALYZECOHERENCEUSECASE Use case for coherence analysis
    %   Orchestrates dynamic coherence analysis
    
    properties (Access = private)
        coherenceService = [];
    end
    
    methods
        function obj = AnalyzeCoherenceUseCase(coherenceService)
            %ANALYZECOHERENCEUSECASE Constructor
            %   coherenceService - CoherenceAnalysisService instance
            obj.coherenceService = coherenceService;
        end
        
        function result = execute(obj, query, selectedPMUIndices, parameters)
            %EXECUTE Execute coherence analysis
            %   query - Query domain object
            %   selectedPMUIndices - Array of PMU indices (must be >= 2)
            %   parameters - Analysis parameters structure
            %   Returns: Coherence analysis result
            
            if length(selectedPMUIndices) < 2
                error('AnalyzeCoherenceUseCase:InsufficientPMUs', ...
                    'At least 2 PMUs required for coherence analysis');
            end
            
            % Get selected PMUs
            query.setSelection(selectedPMUIndices);
            selectedPMUs = query.getSelectedPMUs();
            
            % Extract frequency data
            frequencyData = obj.extractFrequencyData(selectedPMUs);
            
            % Add sampling rate to parameters if not present
            if ~isfield(parameters, 'samplingRate')
                parameters.samplingRate = query.samplingRate;
            end
            
            % Perform analysis
            result = obj.coherenceService.analyze(frequencyData, parameters);
        end
        
        function frequencyData = extractFrequencyData(obj, pmus)
            %EXTRACTFREQUENCYDATA Extract frequency data from PMUs
            numPMUs = length(pmus);
            frequencyData = [];
            
            for i = 1:numPMUs
                pmu = pmus{i};
                freq = pmu.getFrequencyData();
                
                if isempty(freq)
                    error('AnalyzeCoherenceUseCase:NoFrequencyData', ...
                        'PMU %d does not have frequency data', i);
                end
                
                if isempty(frequencyData)
                    frequencyData = zeros(numPMUs, length(freq));
                end
                frequencyData(i, :) = freq';
            end
        end
    end
end

