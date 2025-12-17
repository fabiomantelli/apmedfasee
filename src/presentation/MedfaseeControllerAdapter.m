classdef MedfaseeControllerAdapter < handle
    %MEDFASEECONTROLLERADAPTER Adapter to integrate MainWindowController with medfasee.m
    %   Bridges between legacy GUIDE callbacks and modern architecture
    
    properties (Access = private)
        controller = [];  % MainWindowController instance
    end
    
    methods (Static)
        function adapter = getInstance(handles)
            %GETINSTANCE Get or create adapter instance
            %   Stores instance in handles structure for reuse
            persistent instance
            
            if isempty(instance) || ~isvalid(instance)
                instance = src.presentation.MedfaseeControllerAdapter(handles);
            end
            
            adapter = instance;
        end
    end
    
    methods
        function obj = MedfaseeControllerAdapter(handles)
            %MEDFASEECONTROLLERADAPTER Constructor
            %   handles - GUI handles structure from GUIDE
            obj.controller = src.presentation.MainWindowController(handles);
        end
        
        function onLoadQuery(obj, queryName)
            %ONLOADQUERY Handle query loading from legacy callback
            obj.controller.onQuerySelected(queryName);
        end
        
        function onSelectPMUs(obj, pmuIndices)
            %ONSELECTPMUS Handle PMU selection from legacy callback
            obj.controller.onPMUSelected(pmuIndices);
        end
        
        function onPlot(obj, plotType, parameters)
            %ONPLOT Handle plot request from legacy callback
            obj.controller.onPlotRequested(plotType, parameters);
        end
        
        function controller = getController(obj)
            %GETCONTROLLER Get the underlying controller
            controller = obj.controller;
        end
    end
end



