classdef Query < handle
    %QUERY Domain entity representing a data query/analysis session
    %   Encapsulates query metadata and PMU collection
    
    properties
        name = '';                 % Query name
        systemName = '';            % System name
        samplingRate = 0;           % Sampling rate (samples/second)
        timeLabel = 'Time (s)';    % Time axis label
        rootDirectory = '';         % Root directory path
        dataDirectory = '';         % Data directory path
    end
    
    properties (Access = private)
        pmus = {};                  % Cell array of PMU objects
        selection = [];             % Binary selection vector [1 x N]
        referenceIndex = 1;         % Reference PMU index
    end
    
    methods
        function obj = Query(name)
            %QUERY Constructor
            if nargin > 0
                obj.name = name;
            end
        end
        
        function addPMU(obj, pmu)
            %ADDPMU Add PMU to query
            obj.pmus{end+1} = pmu;
            obj.selection(end+1) = 0;
        end
        
        function pmus = getPMUs(obj)
            %GETPMUS Get all PMUs
            pmus = obj.pmus;
        end
        
        function pmu = getPMU(obj, index)
            %GETPMU Get PMU by index
            if index > 0 && index <= length(obj.pmus)
                pmu = obj.pmus{index};
            else
                pmu = [];
            end
        end
        
        function count = getPMUCount(obj)
            %GETPMUCOUNT Get number of PMUs
            count = length(obj.pmus);
        end
        
        function setSelection(obj, indices)
            %SETSELECTION Set selected PMU indices
            %   indices - Array of PMU indices (1-based)
            obj.selection = zeros(1, length(obj.pmus));
            obj.selection(indices) = 1;
        end
        
        function indices = getSelectedIndices(obj)
            %GETSELECTEDINDICES Get indices of selected PMUs
            indices = find(obj.selection == 1);
        end
        
        function pmus = getSelectedPMUs(obj)
            %GETSELECTEDPMUS Get selected PMU objects
            indices = obj.getSelectedIndices();
            pmus = cell(length(indices), 1);
            for i = 1:length(indices)
                pmus{i} = obj.pmus{indices(i)};
            end
        end
        
        function setReferenceIndex(obj, index)
            %SETREFERENCEINDEX Set reference PMU index
            if index > 0 && index <= length(obj.pmus)
                obj.referenceIndex = index;
            end
        end
        
        function index = getReferenceIndex(obj)
            %GETREFERENCEINDEX Get reference PMU index
            index = obj.referenceIndex;
        end
        
        function isValid = validate(obj)
            %VALIDATE Validate query integrity
            isValid = ~isempty(obj.name) && ...
                      length(obj.pmus) > 0 && ...
                      obj.samplingRate > 0;
        end
    end
end



