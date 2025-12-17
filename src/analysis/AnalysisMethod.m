classdef AnalysisMethod < handle
    %ANALYSISMETHOD Base class for analysis methods
    %   Provides common interface for all analysis methods (RBE, Prony, etc.)
    
    properties (Access = protected)
        dataModel = [];
    end
    
    methods
        function obj = AnalysisMethod(dataModel)
            %ANALYSISMETHOD Constructor
            %   dataModel - DataModel instance with loaded data
            if nargin > 0
                obj.dataModel = dataModel;
            end
        end
        
        function setDataModel(obj, dataModel)
            %SETDATAMODEL Set the data model for analysis
            obj.dataModel = dataModel;
        end
        
        function result = analyze(obj, selectedPMUs, parameters)
            %ANALYZE Perform analysis (to be implemented by subclasses)
            %   selectedPMUs - Array of PMU indices to analyze
            %   parameters - Structure with analysis parameters
            %   Returns: Analysis result structure
            error('AnalysisMethod:NotImplemented', 'analyze() must be implemented by subclass');
        end
        
        function isValid = validateInputs(obj, selectedPMUs, parameters)
            %VALIDATEINPUTS Validate analysis inputs
            %   Returns true if inputs are valid for this analysis method
            isValid = false;
            
            if isempty(obj.dataModel)
                return;
            end
            
            if isempty(selectedPMUs) || length(selectedPMUs) < 1
                return;
            end
            
            if max(selectedPMUs) > obj.dataModel.terminalCount
                return;
            end
            
            isValid = true;
        end
    end
end



