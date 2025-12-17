% MEDFASEE_INTEGRATED - Integrated version using modern architecture
% This file shows how to integrate MainWindowController with medfasee.m
% Replace the callbacks in medfasee.m with these implementations

function pushbutton1_Callback_Integrated(hObject, eventdata, handles)
    % Integrated callback for loading query
    % Get selected query name
    lista_consultas = get(handles.listbox1, 'String');
    indice_selecionado = get(handles.listbox1, 'Value');
    
    if isempty(lista_consultas) || indice_selecionado == 0
        warndlg('Please select a query first', 'Warning');
        return;
    end
    
    queryName = lista_consultas{indice_selecionado};
    [~, queryName, ~] = fileparts(queryName); % Remove .mat extension
    
    % Use adapter to integrate with modern architecture
    adapter = src.presentation.MedfaseeControllerAdapter.getInstance(handles);
    adapter.onLoadQuery(queryName);
end

function listbox2_Callback_Integrated(hObject, eventdata, handles)
    % Integrated callback for PMU selection
    pmuIndices = get(hObject, 'Value');
    
    % Use adapter
    adapter = src.presentation.MedfaseeControllerAdapter.getInstance(handles);
    adapter.onSelectPMUs(pmuIndices);
end

function pushbutton4_Callback_Integrated(hObject, eventdata, handles)
    % Integrated callback for plotting
    % Get selected graphic
    lista_graficos = get(handles.listbox3, 'String');
    indice_selecionado = get(handles.listbox3, 'Value');
    
    if isempty(lista_graficos) || indice_selecionado == 0
        warndlg('Please select a graphic first', 'Warning');
        return;
    end
    
    graphicName = lista_graficos{indice_selecionado};
    [~, graphicName, ~] = fileparts(graphicName); % Remove .m extension
    
    % Determine plot type from graphic name
    if contains(graphicName, 'freq')
        plotType = 'frequency';
        parameters = struct('frequencyType', 'calculated');
    else
        plotType = graphicName;
        parameters = struct();
    end
    
    % Use adapter
    adapter = src.presentation.MedfaseeControllerAdapter.getInstance(handles);
    adapter.onPlot(plotType, parameters);
end



