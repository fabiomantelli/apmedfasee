classdef Plotter < handle
    %PLOTTER Base class for all plotting operations
    %   Provides common functionality for creating plots from DataModel
    
    properties (Access = protected)
        dataModel = [];
        figureHandle = [];
    end
    
    methods
        function obj = Plotter(dataModel)
            %PLOTTER Constructor
            %   dataModel - DataModel instance with loaded data
            if nargin > 0
                obj.dataModel = dataModel;
            end
        end
        
        function setDataModel(obj, dataModel)
            %SETDATAMODEL Set the data model for plotting
            obj.dataModel = dataModel;
        end
        
        function plot(obj, selectedPMUs)
            %PLOT Create plot (to be implemented by subclasses)
            %   selectedPMUs - Array of PMU indices to plot
            error('Plotter:NotImplemented', 'plot() must be implemented by subclass');
        end
        
        function timeVector = getTimeVector(obj)
            %GETTIMEVECTOR Get time vector for plotting
            if isempty(obj.dataModel)
                error('Plotter:NoDataModel', 'DataModel not set');
            end
            timeVector = obj.dataModel.timeVector / obj.dataModel.timeFactor;
        end
        
        function colors = getTerminalColors(obj, terminalIndices)
            %GETTERMINALCOLORS Get color for terminal indices
            if isempty(obj.dataModel)
                error('Plotter:NoDataModel', 'DataModel not set');
            end
            
            colors = cell(length(terminalIndices), 1);
            for i = 1:length(terminalIndices)
                idx = terminalIndices(i);
                if idx <= size(obj.dataModel.terminalColors, 1)
                    colorStr = strtrim(obj.dataModel.terminalColors(idx, :));
                    colors{i} = str2num(colorStr); %#ok<ST2NM>
                else
                    colors{i} = [0 0 0]; % Default black
                end
            end
        end
        
        function terminalNames = getTerminalNames(obj, terminalIndices)
            %GETTERMINALNAMES Get names for terminal indices
            if isempty(obj.dataModel)
                error('Plotter:NoDataModel', 'DataModel not set');
            end
            
            terminalNames = cell(length(terminalIndices), 1);
            for i = 1:length(terminalIndices)
                idx = terminalIndices(i);
                if idx <= length(obj.dataModel.terminalNames)
                    if iscell(obj.dataModel.terminalNames)
                        terminalNames{i} = obj.dataModel.terminalNames{idx};
                    else
                        terminalNames{i} = deblank(obj.dataModel.terminalNames(idx, :));
                    end
                else
                    terminalNames{i} = sprintf('Terminal %d', idx);
                end
            end
        end
        
        function configureAxes(obj, xLabel, yLabel, titleStr, isTimeAxis)
            %CONFIGUREAXES Configure plot axes
            %   isTimeAxis - Optional boolean indicating if X-axis is time
            %   If true or xLabel contains 'tempo'/'time', formats automatically
            if isempty(obj.figureHandle)
                obj.figureHandle = gcf;
            end
            
            % Auto-detect time axis or use explicit flag
            if nargin >= 5 && isTimeAxis
                % Explicit time axis flag
                timeVec = obj.getTimeVector();
                src.visualization.TimeAxisFormatter.format(timeVec, xLabel);
            elseif contains(lower(xLabel), 'tempo') || contains(lower(xLabel), 'time')
                % Auto-detect from label
                timeVec = obj.getTimeVector();
                src.visualization.TimeAxisFormatter.format(timeVec, xLabel);
            else
                xlabel(xLabel);
            end
            
            ylabel(yLabel);
            title(titleStr);
            grid on;
        end
        
        function addLegend(obj, legendEntries)
            %ADDLEGEND Add legend to plot
            if ~isempty(legendEntries)
                legend(legendEntries, 'Location', 'best');
            end
        end
    end
end

