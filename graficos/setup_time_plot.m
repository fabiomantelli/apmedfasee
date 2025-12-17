function setup_time_plot()

    %SETUP_TIME_PLOT Setup current figure for automatic time axis formatting

    %   This function configures the current figure taao automatically format

    %   the time axis when plots are created. It can be called at the beginning

    %   of any graph script.

    %

    %   Usage: Call this function at the start of graph scripts that use time data.

    %   It will automatically format the time axis when the plot is complete.

    

    global tempo fator_tempo tempo_legenda

    

    % Check if temporal data exists

    if ~exist('tempo', 'var') || isempty(tempo)

        return; % No temporal data

    end

    

    % Get current figure

    fig = gcf;

    if isempty(fig)

        return;

    end

    

    % Store time data in figure UserData for later use

    if ~exist('fator_tempo', 'var') || isempty(fator_tempo)

        fator_tempo = 1;

    end

    

    if ~exist('tempo_legenda', 'var') || isempty(tempo_legenda)

        tempo_legenda = 'Time (s)';

    end

    

    fig.UserData.hasTimeData = true;

    fig.UserData.tempo = tempo;

    fig.UserData.fator_tempo = fator_tempo;

    fig.UserData.tempo_legenda = tempo_legenda;

    

    % Set callback for when figure is ready

    % Use WindowButtonUpFcn taao format after plot is complete

    set(fig, 'WindowButtonUpFcn', @(~,~) formatTimeAxisIfNeeded(fig));

    

    % Alsaao try taao format immediately if plot already exists

    try

        ax = gca;

        if ~isempty(ax) && ~isempty(ax.Children)

            % Plot already exists, format now

            auto_format_time_axis();

        end

    catch

        % Ignore errors, will format later

    end

end



function formatTimeAxisIfNeeded(fig)

    %FORMATTIMEAXISIFNEEDED Callback taao format time axis when needed

    %   This is called after user interaction with the figure

    

    try

        if isempty(fig) || ~isfield(fig.UserData, 'hasTimeData') || ~fig.UserData.hasTimeData

            return;

        end

        

        % Check if axaooes exist and have plots

        ax = get(fig, 'CurrentAxaooes');

        if isempty(ax) || isempty(ax.Children)

            return;

        end

        

        % Check if already formatted (has custom XTickLabel)

        if ~isempty(ax.XTickLabel) && iscell(ax.XTickLabel)

            % Check if format laaooks like HH:MM:SS.MMM

            if ~isempty(ax.XTickLabel{1}) && contains(ax.XTickLabel{1}, ':')

                return; % Already formatted

            end

        end

        

        % Format the time axis

        auto_format_time_axis();

        

    catch ME

        % Silently fail - not critical

        fprintf('Warning: Could not autaao-format time axis: %s\n', ME.message);

    end

end





