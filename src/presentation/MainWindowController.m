classdef MainWindowController < handle
    %MAINWINDOWCONTROLLER Controller for main application window
    %   Handles GUI events and delegates to use cases
    
    properties (Access = private)
        handles = [];              % GUI handles structure
        queryRepository = [];      % Query repository
        loadQueryUseCase = [];     % Load query use case
        currentQuery = [];         % Currently loaded query
    end
    
    methods
        function obj = MainWindowController(handles)
            %MAINWINDOWCONTROLLER Constructor
            %   handles - GUI handles structure from GUIDE
            obj.handles = handles;
            
            % Initialize repository and use cases
            queriesDir = src.infrastructure.PathManager.getQueriesDirectory();
            obj.queryRepository = src.repository.MatFileQueryRepository(queriesDir);
            obj.loadQueryUseCase = src.application.LoadQueryUseCase(obj.queryRepository);
            
            % Initialize UI
            obj.initializeUI();
        end
        
        function onQuerySelected(obj, queryName)
            %ONQUERYSELECTED Handle query selection event
            try
                query = obj.loadQueryUseCase.execute(queryName);
                obj.currentQuery = query;
                
                % Update UI with query data
                obj.updatePMUList();
                obj.enablePMUSelection();
                
            catch ME
                warndlg(['Error loading query: ' ME.message], 'Error');
            end
        end
        
        function onPMUSelected(obj, pmuIndices)
            %ONPMUSELECTED Handle PMU selection event
            if isempty(obj.currentQuery)
                return;
            end
            
            obj.currentQuery.setSelection(pmuIndices);
            obj.enableGraphicsSelection();
        end
        
        function onPlotRequested(obj, plotType, parameters)
            %ONPLOTREQUESTED Handle plot request
            if isempty(obj.currentQuery)
                warndlg('Please load a query first', 'Warning');
                return;
            end
            
            selectedIndices = obj.currentQuery.getSelectedIndices();
            if isempty(selectedIndices)
                warndlg('Please select at least one PMU', 'Warning');
                return;
            end
            
            % Delegate to appropriate use case based on plot type
            if strcmpi(plotType, 'frequency')
                obj.plotFrequency(selectedIndices, parameters);
            else
                warndlg(['Unknown plot type: ' plotType], 'Error');
            end
        end
    end
    
    methods (Access = private)
        function initializeUI(obj)
            %INITIALIZEUI Initialize UI components
            % Load available queries
            queryNames = obj.queryRepository.listQueries();
            if ~isempty(queryNames)
                set(obj.handles.listbox1, 'String', queryNames);
                set(obj.handles.listbox1, 'Value', 1);
            end
        end
        
        function updatePMUList(obj)
            %UPDATEPMULIST Update PMU listbox with current query PMUs
            pmus = obj.currentQuery.getPMUs();
            pmuNames = cell(length(pmus), 1);
            for i = 1:length(pmus)
                pmuNames{i} = pmus{i}.name;
            end
            set(obj.handles.listbox2, 'String', pmuNames);
            set(obj.handles.listbox2, 'Value', 1);
        end
        
        function enablePMUSelection(obj)
            %ENABLEPMUSELECTION Enable PMU selection controls
            set(obj.handles.listbox2, 'Enable', 'on');
        end
        
        function enableGraphicsSelection(obj)
            %ENABLEGRAPHICSSELECTION Enable graphics selection controls
            set(obj.handles.listbox3, 'Enable', 'on');
            set(obj.handles.pushbutton4, 'Enable', 'on');
        end
        
        function plotFrequency(obj, selectedIndices, parameters)
            %PLOTFREQUENCY Plot frequency data
            frequencyService = src.services.FrequencyAnalysisService();
            plotter = src.visualization.FrequencyPlotter();
            useCase = src.application.PlotFrequencyUseCase(frequencyService, plotter);
            
            frequencyType = 'calculated';
            if isfield(parameters, 'frequencyType')
                frequencyType = parameters.frequencyType;
            end
            
            useCase.execute(obj.currentQuery, selectedIndices, frequencyType);
        end
    end
end

