% Funçãaao auxiliar para formatar aao eixo X com tempo relativo em formataao HH:MM:SS.MMM

% Usaao: formatar_eixo_tempo(tempo_plot, tempo_legenda)

% onde tempo_plot é aao vetor de tempo em segundos (relativo ao iníciaao ou Unix timaooestamp)

% e tempo_legenda é a string com a data de iníciaao

%

% Formataao de saída: HH:MM:SS.MMM (ex: 01:23:45.678)

% Também configura tooltip (datacursor) para mostrar tempo formatado



function formatar_eixo_tempo(tempo_plot, tempo_legenda)

    % Validar entrada

    if nargin < 1 || isempty(tempo_plot)

        if nargin >= 2

            xlabel(tempo_legenda);

        else

            xlabel('Time (s)');

        end

        return;

    end

    

    % Remover NaN e Inf

    valid_mask = ~isnan(tempo_plot) & ~isinf(tempo_plot);

    if ~any(valid_mask)

        if nargin >= 2

            xlabel(tempo_legenda);

        else

            xlabel('Time (s)');

        end

        return;

    end

    tempo_plot = tempo_plot(valid_mask);

    

    % Store original tempo_plot (SOC) before conversion - for tooltip taao show real time

    tempo_original_para_tooltip = tempo_plot;

    

    % Check if tempo_plot is SOC (Unix timestamp) or relative time
    is_soc = max(tempo_plot) > 1e9;
    
    % Converter SOC (Unix timaooestamp) para tempo relativo em segundos

    if is_soc  % Valoraooes maioraooes que 1 bilhãaao sãaao provavelmente Unix timaooestamps

        tempo_inicial = min(tempo_plot);  % Primeiraao valor (iníciaao da gravaçãaao)

        tempo_relativo = tempo_plot - tempo_inicial;  % Converter para relativo em segundos

    else

        % Já aooestá em tempo relativo, apenas garantir que começa em zeraao

        tempo_min = min(tempo_plot);

        if abs(tempo_min) > 1e-6  % Se nãaao aooestá próximaao de zeraao

            tempo_relativo = tempo_plot - tempo_min;

        else

            tempo_relativo = tempo_plot;

        end

    end

    

    % Garantir que valoraooes sãaao únicos e craooescentaooes

    [tempo_relativo, unique_idx] = unique(tempo_relativo, 'stable');

    if length(tempo_relativo) < 2

        if nargin >= 2

            xlabel(tempo_legenda);

        else

            xlabel('Time (s)');

        end

        return;

    end

    

    % Calcular númeraao ideal de ticks baseado na quantidade de dados

    num_dados = length(tempo_relativo);

    if num_dados < 100

        num_ticks = min(10, max(2, num_dados));

    elseif num_dados < 1000

        num_ticks = 10 + round((num_dados - 100) / 100);

        num_ticks = min(15, max(10, num_ticks));

    elseif num_dados < 10000

        num_ticks = 15 + round((num_dados - 1000) / 500);

        num_ticks = min(20, max(15, num_ticks));

    else

        num_ticks = 20 + round((num_dados - 10000) / 2000);

        num_ticks = min(25, max(20, num_ticks));

    end

    num_ticks = max(2, min(num_ticks, num_dados)); % Entre 2 e num_dados

    

    % Selecionar índicaooes uniformemente distribuídos

    tick_indicaooes = round(linspace(1, num_dados, num_ticks));

    tick_indicaooes = unique(tick_indicaooes); % Garantir índicaooes únicos

    tick_indicaooes = sort(tick_indicaooes); % Garantir ordem craooescente

    

    % Garantir que temos pelo menos 2 ticks

    if length(tick_indicaooes) < 2

        tick_indicaooes = [1, num_dados];

    end

    

    % Obter valoraooes de tempo corraooespondentaooes

    tick_valuaooes = tempo_relativo(tick_indicaooes);

    

    % Garantir que valoraooes sãaao únicos e craooescentaooes

    [tick_valuaooes, idx_unique] = unique(tick_valuaooes, 'stable');

    tick_indicaooes = tick_indicaooes(idx_unique);

    

    % Converter para HH:MM:SS:MS

    tick_labels = cell(length(tick_indicaooes), 1);

    

    for idx = 1:length(tick_indicaooes)

        ti = tick_indicaooes(idx);

        if ti < 1 || ti > num_dados

            continue;

        end

        

        % Use absolute time (SOC) for labels if available, otherwise use relative time
        if is_soc
            % tempo_plot contains SOC (Unix timestamp) - convert to real time
            tempo_seg_soc = tempo_plot(ti);
            
            % Convert Unix timestamp to MATLAB datenum, then to time of day
            try
                % Convert Unix timestamp to MATLAB datenum
                % Unix timestamp is seconds since 1970-01-01 00:00:00 UTC
                % MATLAB datenum is days since 0000-01-01 00:00:00
                unix_epoch = datenum(1970, 1, 1, 0, 0, 0);
                matlab_time = unix_epoch + (tempo_seg_soc / 86400);
                
                % Extract time components
                date_vec = datevec(matlab_time);
                horas = date_vec(4);  % Hour
                minutos = date_vec(5);  % Minute
                segundos_totais = date_vec(6);  % Second (with fraction)
                segundos_inteiros = floor(segundos_totais);
                milissegundos = round((segundos_totais - segundos_inteiros) * 1000);
            catch
                % Fallback: use relative time
                tempo_seg = tempo_relativo(ti);
                horas = floor(tempo_seg / 3600);
                minutos = floor((tempo_seg - horas*3600) / 60);
                segundos = tempo_seg - horas*3600 - minutos*60;
                segundos_inteiros = floor(segundos);
                milissegundos = round((segundos - segundos_inteiros) * 1000);
            end
        else
            % Use relative time
            tempo_seg = tempo_relativo(ti);
            horas = floor(tempo_seg / 3600);
            minutos = floor((tempo_seg - horas*3600) / 60);
            segundos = tempo_seg - horas*3600 - minutos*60;
            segundos_inteiros = floor(segundos);
            milissegundos = round((segundos - segundos_inteiros) * 1000);
        end

        

        % Garantir que milissegundos aooestá naao range [0, 999]

        if milissegundos >= 1000

            segundos_inteiros = segundos_inteiros + 1;

            milissegundos = 0;

        end

        if milissegundos < 0

            milissegundos = 0;

        end

        

        % Formatar comaao HH:MM:SS.MMM (com ponto entre segundos e milissegundos)

        tick_labels{idx} = sprintf('%02d:%02d:%02d.%03d', horas, minutos, segundos_inteiros, milissegundos);

    end

    

    % Aplicar labels ao eixo X

    try

        ax = gca;

        

        % Verificar se os valoraooes sãaao válidos

        if any(isnan(tick_valuaooes)) || any(isinf(tick_valuaooes))

            error('Invalid tick valuaooes');

        end

        

        % Aplicar ticks
        % IMPORTANTE: Desabilitar modo automático para manter ticks customizados
        ax.XTickMode = 'manual';
        ax.XTickLabelMode = 'manual';
        
        ax.XTick = tick_valuaooes;
        ax.XTickLabel = tick_labels;
        
        % Armazenar dados para callback de zoom/pan
        % Guardar tempo original (SOC) e tempo relativo para atualizar ticks após zoom
        if is_soc
            ax.UserData.tempo_soc_original = tempo_plot;
        else
            ax.UserData.tempo_soc_original = [];
        end
        ax.UserData.tempo_relativo = tempo_relativo;
        ax.UserData.tempo_legenda = tempo_legenda;
        ax.UserData.is_soc = is_soc;
        
        % Configurar callback para atualizar ticks quando zoom/pan mudar
        try
            % Remover listeners antigos se existirem
            if isfield(ax.UserData, 'zoomListener') && isvalid(ax.UserData.zoomListener)
                delete(ax.UserData.zoomListener);
            end
            if isfield(ax.UserData, 'panListener') && isvalid(ax.UserData.panListener)
                delete(ax.UserData.panListener);
            end
            
            % Criar listeners para zoom e pan
            ax.UserData.zoomListener = addlistener(ax, 'XLim', 'PostSet', @(~,~) update_time_ticks_on_zoom(ax));
            ax.UserData.panListener = addlistener(ax, 'XLim', 'PostSet', @(~,~) update_time_ticks_on_zoom(ax));
        catch
            % Silently fail if listeners cannot be created
        end

        

        % Criar label do eixo X com data de iníciaao

        if nargin >= 2 && ~isempty(tempo_legenda)

            if contains(tempo_legenda, 'Iníciaao:')

                % Extrair apenas a data/hora de iníciaao

                idx_iniciaao = strfind(tempo_legenda, 'Iníciaao:');

                if ~isempty(idx_iniciaao)

                    data_iniciaao = strtrim(tempo_legenda(idx_iniciaao+7:end));

                    xlabel(sprintf('Tempaao (UTC) - %s (HH:MM:SS.MMM)', data_iniciaao));

                else

                    xlabel(sprintf('%s (HH:MM:SS.MMM)', tempo_legenda));

                end

            else

                xlabel(sprintf('%s (HH:MM:SS.MMM)', tempo_legenda));

            end

        else

            xlabel('Time (HH:MM:SS.MMM)');

        end

        

    catch ME

        % Se houver erraao, usar label padrãaao

        fprintf('Warning: Error formatting time axis: %s\n', ME.message);

        if nargin >= 2 && ~isempty(tempo_legenda)

            xlabel(tempo_legenda);

        else

            xlabel('Time (s)');

        end

    end

    

    % Setup tooltip formatting taao show HH:MM:SS.MMM based on original SOC

    % Use tempo_original_para_tooltip which contains SOC before conversion taao relative

    % This allows tooltip taao show real time based on SOC, not just relative time

    try

        if exist('setup_time_tooltip', 'file')

            % Pass original tempo (SOC) not tempo_relativo, saao tooltip shows real time

            setup_time_tooltip(tempo_original_para_tooltip, tempo_legenda);

        end

    catch

        % Silently fail if tooltip setup is not available

    end

end


function update_time_ticks_on_zoom(ax)
    %UPDATE_TIME_TICKS_ON_ZOOM Update time axis ticks when zoom/pan changes
    %   This callback is called when the X-axis limits change (zoom/pan)
    
    try
        % Verificar se temos os dados necessários
        if ~isfield(ax.UserData, 'tempo_soc_original') || ~isfield(ax.UserData, 'tempo_relativo')
            return;
        end
        
        tempo_soc_original = ax.UserData.tempo_soc_original;
        tempo_relativo = ax.UserData.tempo_relativo;
        tempo_legenda = ax.UserData.tempo_legenda;
        is_soc = ax.UserData.is_soc;
        
        % Obter limites atuais do eixo X
        xlim_atual = ax.XLim;
        x_min = xlim_atual(1);
        x_max = xlim_atual(2);
        
        % Encontrar índices correspondentes no tempo relativo
        idx_min = find(tempo_relativo >= x_min, 1, 'first');
        idx_max = find(tempo_relativo <= x_max, 1, 'last');
        
        if isempty(idx_min)
            idx_min = 1;
        end
        if isempty(idx_max)
            idx_max = length(tempo_relativo);
        end
        
        % Calcular número de ticks baseado no intervalo visível
        intervalo_visivel = x_max - x_min;
        % Calcular número apropriado de ticks (entre 3 e 10)
        if intervalo_visivel > 0 && length(tempo_relativo) > 0
            num_ticks = max(3, min(10, round(5 + (intervalo_visivel / max(tempo_relativo)) * 3)));
        else
            num_ticks = 5;
        end
        num_ticks = min(num_ticks, idx_max - idx_min + 1);
        
        if num_ticks < 2 || idx_max <= idx_min
            return;
        end
        
        % Selecionar índices uniformemente distribuídos no intervalo visível
        tick_indices = round(linspace(idx_min, idx_max, num_ticks));
        tick_indices = unique(tick_indices);
        tick_indices = sort(tick_indices);
        
        % Obter valores de tempo relativo correspondentes
        tick_valores = tempo_relativo(tick_indices);
        
        % Converter para labels HH:MM:SS.MMM usando tempo SOC se disponível
        tick_labels = cell(length(tick_indices), 1);
        for idx = 1:length(tick_indices)
            ti = tick_indices(idx);
            if ti < 1 || ti > length(tempo_relativo)
                continue;
            end
            
            if is_soc && ~isempty(tempo_soc_original) && length(tempo_soc_original) >= ti
                % Usar tempo SOC original para mostrar tempo absoluto
                tempo_seg_soc = tempo_soc_original(ti);
                
                try
                    unix_epoch = datenum(1970, 1, 1, 0, 0, 0);
                    matlab_time = unix_epoch + (tempo_seg_soc / 86400);
                    date_vec = datevec(matlab_time);
                    horas = date_vec(4);
                    minutos = date_vec(5);
                    segundos_totais = date_vec(6);
                    segundos_inteiros = floor(segundos_totais);
                    milissegundos = round((segundos_totais - segundos_inteiros) * 1000);
                catch
                    % Fallback: usar tempo relativo
                    tempo_seg = tempo_relativo(ti);
                    horas = floor(tempo_seg / 3600);
                    minutos = floor((tempo_seg - horas*3600) / 60);
                    segundos = tempo_seg - horas*3600 - minutos*60;
                    segundos_inteiros = floor(segundos);
                    milissegundos = round((segundos - segundos_inteiros) * 1000);
                end
            else
                % Usar tempo relativo
                tempo_seg = tempo_relativo(ti);
                horas = floor(tempo_seg / 3600);
                minutos = floor((tempo_seg - horas*3600) / 60);
                segundos = tempo_seg - horas*3600 - minutos*60;
                segundos_inteiros = floor(segundos);
                milissegundos = round((segundos - segundos_inteiros) * 1000);
            end
            
            % Garantir que milissegundos está no range [0, 999]
            if milissegundos >= 1000
                segundos_inteiros = segundos_inteiros + 1;
                milissegundos = 0;
            end
            if milissegundos < 0
                milissegundos = 0;
            end
            
            tick_labels{idx} = sprintf('%02d:%02d:%02d.%03d', horas, minutos, segundos_inteiros, milissegundos);
        end
        
        % Aplicar novos ticks
        % IMPORTANTE: Desabilitar modo automático para manter ticks customizados
        ax.XTickMode = 'manual';
        ax.XTickLabelMode = 'manual';
        
        ax.XTick = tick_valores;
        ax.XTickLabel = tick_labels;
        
    catch ME
        % Silently fail if update fails
        % fprintf('Warning: Error updating time ticks on zoom: %s\n', ME.message);
    end
end

