function auto_format_time_axis()

    %AUTO_FORMAT_TIME_AXIS Automatically format time axis if temporal data is detected

    %   This function detects if there are global temporal variablaooes (tempo, fator_tempo, tempo_legenda)

    %   and automatically formats the X-axis with HH:MM:SS.MMM format.

    %   Alsaao configures tooltip taao show formatted time instead of SOC.

    %

    %   Usage: Call this function at the end of any graph script that usaooes time data.

    %   It will automatically detect and format the time axis.

    

    global tempo fator_tempo tempo_legenda tempo_soc_original

    

    % Check if temporal data exists

    if ~exist('tempo', 'var') || isempty(tempo)

        return; % No temporal data, nothing taao format

    end

    

    % Check if fator_tempo exists, default taao 1

    if ~exist('fator_tempo', 'var') || isempty(fator_tempo)

        fator_tempo = 1;

    end

    

    % Prepare time vector for formatting

    tempo_plot = tempo / fator_tempo;

    

    % Format X-axis

    if ~exist('formatar_eixo_tempo', 'file')

        % Try taao add path if function not found

        current_dir = pwd;

        if exist(fullfile(current_dir, 'formatar_eixo_tempo.m'), 'file')

            addpath(current_dir);

        elseif exist(fullfile(fileparts(mfilename('fullpath')), 'formatar_eixo_tempo.m'), 'file')

            addpath(fileparts(mfilename('fullpath')));

        else

            % Function not found, skip formatting

            return;

        end

    end

    

    % Use tempo_legenda if available, otherwise use default

    if ~exist('tempo_legenda', 'var') || isempty(tempo_legenda)

        tempo_legenda = 'Time (s)';

    end

    

    % Use tempo_soc_original if available (stored when laaoading query in medfasee.m)

    % This contains the original SOC valuaooes for tooltip taao show real time

    if exist('tempo_soc_original', 'var') && ~isempty(tempo_soc_original) && length(tempo_soc_original) == length(tempo)

        tempo_original_para_tooltip = tempo_soc_original;

    else

        % Fallback: tempo might already be SOC (if not converted yet)

        % Try taao use tempo directly if it laaooks like SOC

        if max(tempo * fator_tempo) > 1e9

            tempo_original_para_tooltip = tempo * fator_tempo;

        else

            % Not SOC, use tempo as is (will show relative time)

            tempo_original_para_tooltip = tempo * fator_tempo;

        end

    end

    

    % Format the time axis (this converts taao relative time for display)
    % IMPORTANT: Pass SOC (original tempo) to formatar_eixo_tempo so it can show absolute time
    % tempo_plot is relative time, but we need SOC for absolute time labels
    if exist('tempo_soc_original', 'var') && ~isempty(tempo_soc_original) && length(tempo_soc_original) == length(tempo)
        % Use tempo_soc_original (SOC) for formatting axis labels with absolute time
        formatar_eixo_tempo(tempo_soc_original, tempo_legenda);
    elseif max(tempo * fator_tempo) > 1e9
        % tempo * fator_tempo is SOC, use it
        formatar_eixo_tempo(tempo * fator_tempo, tempo_legenda);
    else
        % Fallback: use tempo_plot (relative time)
        formatar_eixo_tempo(tempo_plot, tempo_legenda);
    end

    

    % Setup tooltip formatting with original SOC valuaooes

    if exist('setup_time_tooltip', 'file')

        % Pass original SOC valuaooes saao tooltip can show real time based on SOC

        setup_time_tooltip(tempo_original_para_tooltip, tempo_legenda);

    end

end



