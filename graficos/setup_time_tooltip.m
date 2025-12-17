function setup_time_tooltip(tempo_plot, tempo_legenda)

    %SETUP_TIME_TOOLTIP Configure datacursor tooltip to show formatted time

    %   tempo_plot - Time vector (relative time in seconds or Unix timestamp)

    %   tempo_legenda - Time label string

    

    if nargin < 1 || isempty(tempo_plot)

        return;

    end

    

    if nargin < 2

        tempo_legenda = 'Time';

    end

    

    try

        % Get current figure

        fig = gcf;

        if isempty(fig)

            return;

        end

        

        % Get datacursor mode

        dcm = datacursormode(fig);

        if isempty(dcm)

            return;

        end

        

        % Store time data in figure's UserData for callback access

        fig.UserData.timeVector = tempo_plot;

        fig.UserData.timeLabel = tempo_legenda;

        

        % Set update function for datacursor

        set(dcm, 'UpdateFcn', @formatDataCursorCallback);

        

    catch ME

        % Silently fail if datacursor is not available

        % This is not critical functionality

        fprintf('Warning: Could not setup time tooltip: %s\n', ME.message);

    end

end



function output_txt = formatDataCursorCallback(~, event_obj, ~, ~)

    %FORMATDATACURSORCALLBACK Callback to format datacursor tooltip with HH:MM:SS.MMM

    %   This callback is called when user hovers over plot points

    

    try

        % Get figure handle

        fig = ancestor(event_obj.Target, 'figure');

        if isempty(fig) || ~isfield(fig.UserData, 'timeVector')

            % Fallback to default format

            pos = get(event_obj, 'Position');

            output_txt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};

            return;

        end

        

        % Get stored time vector

        tempo_plot = fig.UserData.timeVector;

        tempo_legenda = fig.UserData.timeLabel;

        

        % Get cursor position

        pos = get(event_obj, 'Position');

        x_val = pos(1);  % X value (time) - this is relative time from the plot axis

        

        % IMPORTANT: x_val is relative time (from the plot axis which shows relative time)

        % tempo_plot contains SOC (Unix timestamp) values

        % We need to find which SOC corresponds to this relative time

        

        % Check if tempo_plot is SOC (Unix timaooestamp) or relative time

        is_soc = max(tempo_plot) > 1e9;

        

        if is_soc

            % tempo_plot contains SOC values

            % x_val is relative time, so we need to convert tempo_plot to relative

            % to find the matching index, then use the SOC value

            tempo_inicial_soc = min(tempo_plot);

            tempo_relativo_plot = tempo_plot - tempo_inicial_soc;

            

            % Find closest relative time value to match x_val

            [~, idx] = min(abs(tempo_relativo_plot - x_val));

            if idx > length(tempo_plot)

                idx = length(tempo_plot);

            elseif idx < 1

                idx = 1;

            end

            

            % Get the SOC value at this index (this is the real time)

            tempo_seg = tempo_plot(idx);

        else

            % tempo_plot is already relative time

            [~, idx] = min(abs(tempo_plot - x_val));

            if idx > length(tempo_plot)

                idx = length(tempo_plot);

            elseif idx < 1

                idx = 1;

            end

            tempo_seg = tempo_plot(idx);

        end

        

        % Convert SOC (Unix timestamp) to real time

        % If it's a Unix timestamp, convert to date/time

        % Otherwise, use as relative time

        if is_soc

            % SOC is Unix timestamp - convert to real date/time

            % tempo_seg is the SOC value at this point

            % Convert Unix timestamp to MATLAB datenum, then to time of day

            try

                % Convert Unix timestamp to MATLAB datenum

                % Unix timestamp is seconds since 1970-01-01 00:00:00 UTC

                % MATLAB datenum is days since 0000-01-01 00:00:00

                unix_epoch = datenum(1970, 1, 1, 0, 0, 0);

                matlab_time = unix_epoch + (tempo_seg / 86400);

                

                % Extract time components

                date_vec = datevec(matlab_time);

                horas = date_vec(4);  % Hour

                minutos = date_vec(5);  % Minute

                segundos_totais = date_vec(6);  % Second (with fraction)

                segundos_inteiros = floor(segundos_totais);

                milissegundos = round((segundos_totais - segundos_inteiros) * 1000);

            catch

                % Fallback: treat as relative time from start

                tempo_inicial = min(tempo_plot);

                tempo_relativo = tempo_seg - tempo_inicial;

                horas = floor(tempo_relativo / 3600);

                minutos = floor((tempo_relativo - horas*3600) / 60);

                segundos = tempo_relativo - horas*3600 - minutos*60;

                segundos_inteiros = floor(segundos);

                milissegundos = round((segundos - segundos_inteiros) * 1000);

            end

        else

            % Already relative time - use as is

            tempo_min = min(tempo_plot);

            if abs(tempo_min) > 1e-6

                tempo_relativo = tempo_seg - tempo_min;

            else

                tempo_relativo = tempo_seg;

            end

            horas = floor(tempo_relativo / 3600);

            minutos = floor((tempo_relativo - horas*3600) / 60);

            segundos = tempo_relativo - horas*3600 - minutos*60;

            segundos_inteiros = floor(segundos);

            milissegundos = round((segundos - segundos_inteiros) * 1000);

        end

        

        % Ensure milliseconds in range [0, 999]

        if milissegundos >= 1000

            segundos_inteiros = segundos_inteiros + 1;

            milissegundos = 0;

        end

        if milissegundos < 0

            milissegundos = 0;

        end

        

        % Format as HH:MM:SS.MMM

        tempo_formatado = sprintf('%02d:%02d:%02d.%03d', horas, minutos, segundos_inteiros, milissegundos);

        

        % Create output text

        output_txt = {sprintf('Tempo: %s', tempo_formatado), sprintf('Y: %.6f', pos(2))};

        

    catch ME

        % Fallback to default format on error

        pos = get(event_obj, 'Position');

        output_txt = {sprintf('X: %.6f', pos(1)), sprintf('Y: %.6f', pos(2))};

        fprintf('Warning: Error formatting tooltip: %s\n', ME.message);

    end

end



