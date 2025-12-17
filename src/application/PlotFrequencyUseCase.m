classdef PlotFrequencyUseCase < handle
    %PLOTFREQUENCYUSECASE Use case for plotting frequency data
    %   Orchestrates frequency plotting with proper separation of concerns
    
    properties (Access = private)
        frequencyService = [];
        plotter = [];
    end
    
    methods
        function obj = PlotFrequencyUseCase(frequencyService, plotter)
            %PLOTFREQUENCYUSECASE Constructor
            %   frequencyService - IFrequencyAnalysisService implementation
            %   plotter - FrequencyPlotter instance
            obj.frequencyService = frequencyService;
            obj.plotter = plotter;
        end
        
        function execute(obj, query, selectedPMUIndices, frequencyType)
            %EXECUTE Execute the use case
            %   query - Query domain object
            %   selectedPMUIndices - Array of PMU indices to plot
            %   frequencyType - 'pmu' or 'calculated'
            
            if nargin < 4
                frequencyType = 'calculated';
            end
            
            % Get selected PMUs
            selectedPMUs = query.getSelectedPMUs();
            if length(selectedPMUs) ~= length(selectedPMUIndices)
                query.setSelection(selectedPMUIndices);
                selectedPMUs = query.getSelectedPMUs();
            end
            
            if isempty(selectedPMUs)
                error('PlotFrequencyUseCase:NoSelection', 'No PMUs selected');
            end
            
            % Create data model for plotter (temporary bridge)
            dataModel = src.core.DataModel();
            dataModel.terminalCount = query.getPMUCount();
            dataModel.samplingRate = query.samplingRate;
            dataModel.timeLabel = query.timeLabel;
            
            % Extract data from PMUs
            allPMUs = query.getPMUs();
            for i = 1:length(allPMUs)
                pmu = allPMUs{i};
                timeVec = pmu.getTimeVector();
                if i == 1
                    dataModel.timeVector = timeVec;
                end
                
                freqData = pmu.getFrequencyData();
                if ~isempty(freqData)
                    if isempty(dataModel.frequencyData)
                        dataModel.frequencyData = zeros(length(allPMUs), length(freqData));
                    end
                    dataModel.frequencyData(i, :) = freqData';
                end
            end
            
            % Set plotter data model
            obj.plotter.setDataModel(dataModel);
            
            % Plot
            obj.plotter.plot(selectedPMUIndices, frequencyType);
        end
    end
end



