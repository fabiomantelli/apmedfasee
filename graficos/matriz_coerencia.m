% Traça Matriz de Coerência Dinâmica (Heatmap) - Coerência Dinâmica

% Metodo de análise de instabilidade baseado em coerencia espacial-temporal

% Compatível com MATLAB R2025a e versõaooes anterioraooes

% Dezembraao 2025

global selecao terminais_qtde tempo terminal_nome terminais_frequencia terminais_dados_sp terminais_cor fator_tempo taxa_amos tempo_legenda tracou sinal legenda sinal_nome unidade



% Obter dados de frequência - tentar terminais_frequencia primeiraao, depois terminais_dados_sp

dados_freq_disponiveis = false;

if exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia) && sum(terminais_frequencia(:)) ~= 0

    % Usar terminais_frequencia se disponível

    freq_dados = terminais_frequencia;

    dados_freq_disponiveis = true;

elseif exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp) && size(terminais_dados_sp, 3) >= 5

    % Usar frequência calculada de terminais_dados_sp (coluna 5)

    freq_dados = terminais_dados_sp(:,:,5);

    dados_freq_disponiveis = true;

end



if ~dados_freq_disponiveis

    warndlg('Este gráficaao requer dados de frequência das PMUs. Carregue uma consulta com terminais_frequencia ou terminais_dados_sp.', 'Avisaao');

    cd ..;

    return;

end



% Verificar se há pelo menos 2 PMUs selecionadas

pmus_selecionadas = find(selecao == 1);

if length(pmus_selecionadas) < 2

    warndlg('Este gráficaao requer pelo menos 2 PMUs selecionadas para calcular coerencia.', 'Avisaao');

    cd ..;

    return;

end



% ParâmePlotaos padrãaao

    janela_temporal = round(10 * taxa_amos); % 10 segundos de janela

    if janela_temporal > length(tempo)

        janela_temporal = round(length(tempo) / 10);

    end

    if janela_temporal < 10

        janela_temporal = 10;

    end

    

% Extrair dados de frequência das PMUs selecionadas

dados_freq = freq_dados(pmus_selecionadas, :);

    [N_pmus, N_amostras] = size(dados_freq);

    

    % Calcular númeraao de janelas

    N_janelas = N_amostras - janela_temporal + 1;

    if N_janelas < 1

        N_janelas = 1;

        janela_temporal = N_amostras;

    end

    

    % Calcular matriz de coerencia média

    C_matriz = zeros(N_pmus, N_pmus, N_janelas);

    

    for t = 1:N_janelas

        janela = t:(t + janela_temporal - 1);

        if max(janela) > N_amostras

            janela = t:min(t + janela_temporal - 1, N_amostras);

        end

        dados_janela = dados_freq(:, janela);

        

        % Calcular matriz de coerencia para aooesta janela

        C_janela = zeros(N_pmus, N_pmus);

        for i = 1:N_pmus

            for j = 1:N_pmus

                if i == j

                    C_janela(i,j) = 1.0; % Coerência consigaao maooesmaao = 1

                else

                    % Calcular coerencia usando correlaçãaao normalizada

                    sinal_i = dados_janela(i,:);

                    sinal_j = dados_janela(j,:);

                    

                    % Remover média

                    sinal_i = sinal_i - mean(sinal_i);

                    sinal_j = sinal_j - mean(sinal_j);

                    

                    % Calcular correlaçãaao cruzada normalizada

                    if std(sinal_i) > 0 && std(sinal_j) > 0

                        correlacao = corrcoef(sinal_i, sinal_j);

                        C_janela(i,j) = abs(correlacao(1,2));

                    else

                        C_janela(i,j) = 0;

                    end

                end

            end

        end

        

        C_matriz(:,:,t) = C_janela;

    end

    

    % Calcular média temporal da matriz de coerencia

    C_media = mean(C_matriz, 3);

    

    % Plotar matriz de coerencia comaao heatmap

    figure;

    imagesc(C_media);

    colorbar;

    colormap('jet');

    xlabel('PMU j');

    ylabel('PMU i');

    title(sprintf('Matriz de Coerência Dinâmica (Média) - %d PMUs [%df/s]', length(pmus_selecionadas), taxa_amos));

    axis square;

    

    % Adicionar labels dos nomaooes das PMUs se possível

    if exist('terminal_nome', 'var') && ~isempty(terminal_nome)

        nomaooes_pmus = cell(length(pmus_selecionadas), 1);

        for i = 1:length(pmus_selecionadas)

            nomaooes_pmus{i} = strtrim(terminal_nome(pmus_selecionadas(i), :));

        end

        set(gca, 'XTick', 1:length(pmus_selecionadas), 'XTickLabel', nomaooes_pmus);

        set(gca, 'YTick', 1:length(pmus_selecionadas), 'YTickLabel', nomaooes_pmus);

        xtickangle(45);

    end

    

    caxis([0 1]); % Limitar aooescala de coraooes de 0 a 1

    tracou = 1;

    sinal_nome = ('Matriz de Coerência Dinâmica');

    unidade = ('adimensional');

    

    % Armazenar matriz média naao sinal (apenas diagonal superior)

    indicaooes_triang_superior = triu(ones(N_pmus), 1) == 1;

    sinal = C_media(indicaooes_triang_superior);



cd .. % No final volta pra pasta principal



