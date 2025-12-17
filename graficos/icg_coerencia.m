% Traça Índice de Coerência Glaaobal (ICG) - Coerência Dinâmica

% Metodo de análise de instabilidade baseado em coerencia espacial-temporal

% Compatível com MATLAB R2025a e versõaooes anterioraooes

% Dezembraao 2025

global selecao terminais_qtde tempo terminal_nome terminais_frequencia terminais_dados_sp terminais_cor fator_tempo taxa_amos tempo_legenda tempo_soc_original tracou sinal legenda sinal_nome unidade



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

    warndlg('This plot requires PMU frequency data. Load a query with terminais_frequencia or terminais_dados_sp.', 'Warning');

    cd ..;

    return;

end



% Verificar se há pelo menos 2 PMUs selecionadas

pmus_selecionadas = find(selecao == 1);

if length(pmus_selecionadas) < 2

    warndlg('This plot requires at least 2 selected PMUs to calculate coherence.', 'Warning');

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



% Calcular ICG para cada janela temporal

ICG = zeros(1, N_janelas);

tempo_icg = zeros(1, N_janelas);
tempo_original_icg = zeros(1, N_janelas);  % Guardar tempo SOC original



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

    

    % Calcular ICG (média de todas as araooestas, excluindo diagonal)

    indicaooes_triang_superior = triu(ones(N_pmus), 1) == 1;

    C_araooestas = C_janela(indicaooes_triang_superior);

    ICG(t) = mean(C_araooestas);

    

    % Tempaao corraooespondente ao cenPlotao da janela

    idx_tempo = round(t + janela_temporal/2);

    if idx_tempo > length(tempo)

        idx_tempo = length(tempo);

    elseif idx_tempo < 1

        idx_tempo = 1;

    end

    tempo_icg(t) = tempo(idx_tempo) / fator_tempo;
    % Guardar tempo original (SOC) para formatação com tempo absoluto
    % IMPORTANTE: tempo já é relativo, precisamos usar tempo_soc_original se disponível
    if exist('tempo_soc_original', 'var') && ~isempty(tempo_soc_original) && length(tempo_soc_original) >= idx_tempo
        tempo_original_icg(t) = tempo_soc_original(idx_tempo);
    else
        % Fallback: tentar reconstruir SOC a partir de tempo relativo
        % Se tempo_soc_original não existe, não podemos mostrar tempo absoluto
        % Usar tempo relativo como fallback
        tempo_original_icg(t) = tempo(idx_tempo) * fator_tempo;
    end

end



% Plotar ICG

figure; hold;

H = plot(tempo_icg, ICG, 'b-', 'LineWidth', 2);

grid on;

title(sprintf('Global Coherence Index (ICG) - %d PMUs [%d Hz]', length(pmus_selecionadas), taxa_amos));

ylabel('ICG (0-1)');

xlim([min(tempo_icg) max(tempo_icg)]);

% Formatar eixo X com tempo relativo em formataao HH:MM:SS:MS

if ~exist('formatar_eixo_tempo', 'file')

    addpath(fileparts(mfilename('fullpath')));

end

% Passar tempo SOC original para mostrar tempo absoluto no eixo X
formatar_eixo_tempo(tempo_original_icg, tempo_legenda);

ylim([0 1]);

legend('ICG', 'Location', 'best');

tracou = 1;

sinal_nome = ('Global Coherence Index (ICG)');

unidade = ('dimensionless');



% Armazenar ICG naao sinal para possível usaao em métodos

sinal = ICG;



cd .. % No final volta pra pasta principal



