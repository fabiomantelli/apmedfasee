% Traça Assinatura de Regime Completa - Coerência Dinâmica
%
% Método de análise de instabilidade baseado em coerência espacial-temporal
% Inclui: ICG, Entropia Espacial, Variância do ICG, Derivada do ICG, Entropia Temporal do ICG
%
% Compatível com MATLAB R2025a e versões anteriores
%
% Dezembro 2025

global selecao terminais_qtde tempo terminal_nome terminais_frequencia terminais_dados_sp terminais_cor fator_tempo taxa_amos tempo_legenda tempo_soc_original tracou sinal legenda sinal_nome unidade

% Obter dados de frequência - tentar terminais_frequencia primeiro, depois terminais_dados_sp
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

% Parâmetros padrão
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

% Calcular número de janelas
N_janelas = N_amostras - janela_temporal + 1;

if N_janelas < 1
    N_janelas = 1;
    janela_temporal = N_amostras;
end

% Inicializar arrays
ICG = zeros(1, N_janelas);
H_entropia = zeros(1, N_janelas);
tempo_icg = zeros(1, N_janelas);
tempo_original_icg = zeros(1, N_janelas);

% Calcular ICG e entropia espacial para cada janela temporal
for t = 1:N_janelas
    janela = t:(t + janela_temporal - 1);
    if max(janela) > N_amostras
        janela = t:min(t + janela_temporal - 1, N_amostras);
    end
    dados_janela = dados_freq(:, janela);
    
    % Calcular matriz de coerência para esta janela
    C_janela = zeros(N_pmus, N_pmus);
    for i = 1:N_pmus
        for j = 1:N_pmus
            if i == j
                C_janela(i,j) = 1.0; % Coerência consigo mesmo = 1
            else
                % Calcular coerência usando correlação normalizada
                sinal_i = dados_janela(i,:);
                sinal_j = dados_janela(j,:);
                
                % Remover média
                sinal_i = sinal_i - mean(sinal_i);
                sinal_j = sinal_j - mean(sinal_j);
                
                % Calcular correlação cruzada normalizada
                if std(sinal_i) > 0 && std(sinal_j) > 0
                    correlacao = corrcoef(sinal_i, sinal_j);
                    C_janela(i,j) = abs(correlacao(1,2));
                else
                    C_janela(i,j) = 0;
                end
            end
        end
    end
    
    % Calcular ICG (média de todas as arestas, excluindo diagonal)
    indices_triang_superior = triu(ones(N_pmus), 1) == 1;
    C_arestas = C_janela(indices_triang_superior);
    ICG(t) = mean(C_arestas);
    
    % Calcular entropia de coerência espacial
    soma_arestas = sum(C_arestas);
    if soma_arestas > 0
        p_arestas = C_arestas / soma_arestas;
        % Calcular entropia (evitar log(0))
        p_arestas(p_arestas == 0) = eps;
        H_entropia(t) = -sum(p_arestas .* log(p_arestas));
    else
        H_entropia(t) = 0;
    end
    
    % Tempo correspondente ao centro da janela
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

% Calcular métricas da assinatura de regime
% Variância do ICG em janelas deslizantes
janela_var = min(max(round(janela_temporal/2), 3), length(ICG));
if length(ICG) > 1
    if exist('movvar', 'builtin') || exist('movvar', 'file')
        var_ICG = movvar(ICG, janela_var);
    else
        % Implementação manual
        var_ICG = zeros(size(ICG));
        for i = 1:length(ICG)
            inicio = max(1, i - floor(janela_var/2));
            fim = min(length(ICG), i + floor(janela_var/2));
            var_ICG(i) = var(ICG(inicio:fim));
        end
    end
else
    var_ICG = 0;
end

% Derivada do ICG (dICG/dt)
if length(tempo_icg) > 1
    dt = mean(diff(tempo_icg));
    if dt > 0
        dICG_dt = [0, diff(ICG) / dt];
    else
        dICG_dt = zeros(size(ICG));
    end
else
    dICG_dt = zeros(size(ICG));
end

% Entropia temporal do ICG (em janelas deslizantes)
num_bins = 20;
janela_entropia = max(round(length(ICG)/10), 10);
H_temporal_series = calcular_entropia_temporal_series_local(ICG, num_bins, janela_entropia);
tempo_entropia = tempo_icg(1:length(H_temporal_series));

% Entropia temporal global do ICG
H_temporal_global = calcular_entropia_temporal_local(ICG, num_bins);

% Plotar Assinatura de Regime Completa
figure('Name', 'Regime Signature - Dynamic Coherence', 'Position', [50 50 1400 900]);

% Subplot 1: ICG vs time
subplot(3,3,1);
plot(tempo_icg, ICG, 'b-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('ICG');
title('Global Coherence Index');
ylim([0 1]);

% Subplot 2: Spatial entropy vs time
subplot(3,3,2);
plot(tempo_icg, H_entropia, 'r-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('H_{sp}(t)');
title('Spatial Coherence Entropy');

% Subplot 3: ICG variance vs time
subplot(3,3,3);
plot(tempo_icg, var_ICG, 'g-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('Var(ICG)');
title('ICG Variance');
ylim([0 max([max(var_ICG), 0.01])]);

% Subplot 4: ICG derivative vs time
subplot(3,3,4);
plot(tempo_icg, dICG_dt, 'm-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('dICG/dt');
title('ICG Derivative');

% Subplot 5: Temporal entropy of ICG vs time
subplot(3,3,5);
plot(tempo_entropia, H_temporal_series, 'c-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('H_{temp}(t)');
title('Temporal Entropy of ICG');
hold on;
plot(tempo_icg([1 end]), [H_temporal_global H_temporal_global], 'c--', 'LineWidth', 1);
hold off;
legend('H_{temp}(t)', sprintf('H_{temp,global}=%.3f', H_temporal_global), 'Location', 'best', 'FontSize', 8);

% Subplot 6: ICG and Variance overlaid
subplot(3,3,6);
yyaxis left
plot(tempo_icg, ICG, 'b-', 'LineWidth', 2);
ylabel('ICG', 'Color', 'b');
ylim([0 1]);
yyaxis right
plot(tempo_icg, var_ICG, 'g--', 'LineWidth', 1.5);
ylabel('Var(ICG)', 'Color', 'g');
xlabel(tempo_legenda);
title('ICG and Variance');
grid on;
legend('ICG', 'Var(ICG)', 'Location', 'best');

% Subplot 7: ICG and Derivative overlaid
subplot(3,3,7);
yyaxis left
plot(tempo_icg, ICG, 'b-', 'LineWidth', 2);
ylabel('ICG', 'Color', 'b');
ylim([0 1]);
yyaxis right
plot(tempo_icg, dICG_dt, 'm--', 'LineWidth', 1.5);
ylabel('dICG/dt', 'Color', 'm');
xlabel(tempo_legenda);
title('ICG and Derivative');
grid on;
legend('ICG', 'dICG/dt', 'Location', 'best');

% Subplot 8: Entropies overlaid
subplot(3,3,8);
yyaxis left
plot(tempo_icg, H_entropia, 'r-', 'LineWidth', 2);
ylabel('H_{sp}(t)', 'Color', 'r');
yyaxis right
plot(tempo_entropia, H_temporal_series, 'c-', 'LineWidth', 2);
ylabel('H_{temp}(t)', 'Color', 'c');
xlabel(tempo_legenda);
title('Spatial and Temporal Entropies');
grid on;
legend('H_{sp}', 'H_{temp}', 'Location', 'best');

% Subplot 9: Consolidated panel - all normalized metrics
subplot(3,3,9);
% Normalize all metrics for comparison
ICG_norm = (ICG - min(ICG)) / (max(ICG) - min(ICG) + eps);
H_esp_norm = (H_entropia - min(H_entropia)) / (max(H_entropia) - min(H_entropia) + eps);
var_norm = var_ICG / (max(var_ICG) + eps);
dICG_norm = (dICG_dt - min(dICG_dt)) / (max(dICG_dt) - min(dICG_dt) + eps);
H_temp_norm = (H_temporal_series - min(H_temporal_series)) / (max(H_temporal_series) - min(H_temporal_series) + eps);

plot(tempo_icg, ICG_norm, 'b-', 'LineWidth', 1.5); hold on;
plot(tempo_icg, H_esp_norm, 'r-', 'LineWidth', 1.5);
plot(tempo_icg, var_norm, 'g--', 'LineWidth', 1.5);
plot(tempo_icg, dICG_norm, 'm--', 'LineWidth', 1.5);
plot(tempo_entropia, H_temp_norm, 'c--', 'LineWidth', 1.5);
hold off;
grid on;
xlabel(tempo_legenda);
ylabel('Normalized Values');
title('Regime Signature - All Metrics');
legend('ICG', 'H_{sp}', 'Var(ICG)', 'dICG/dt', 'H_{temp}', 'Location', 'best', 'FontSize', 7);

% Formatar eixo X com tempo relativo
if ~exist('formatar_eixo_tempo', 'file')
    addpath(fileparts(mfilename('fullpath')));
end

% Aplicar formatação de tempo em todos os subplots
% Usar tempo SOC original para mostrar tempo absoluto no eixo X
for sp = 1:9
    subplot(3,3,sp);
    formatar_eixo_tempo(tempo_original_icg, tempo_legenda);
end

% Configurar tooltip com tempo original (SOC) para mostrar hora real
% Isso deve ser feito após formatar_eixo_tempo, pois setup_time_tooltip precisa do tempo original
if exist('setup_time_tooltip', 'file')
    try
        setup_time_tooltip(tempo_original_icg, tempo_legenda);
    catch
        % Silently fail if tooltip setup fails
    end
end

tracou = 1;
sinal_nome = 'Complete Regime Signature';
unidade = 'dimensionless';

% Armazenar sinal para possível uso em métodos
sinal = ICG;

% Mostrar informações no console
fprintf('\n=== Regime Signature - Results ===\n');
fprintf('PMUs analyzed: %d\n', length(pmus_selecionadas));
fprintf('Temporal window: %d samples (%.2f s)\n', janela_temporal, janela_temporal/taxa_amos);
fprintf('\n--- Basic Metrics ---\n');
fprintf('Mean ICG: %.4f\n', mean(ICG));
fprintf('Minimum ICG: %.4f\n', min(ICG));
fprintf('Maximum ICG: %.4f\n', max(ICG));
fprintf('Mean spatial entropy: %.4f\n', mean(H_entropia));
fprintf('\n--- Regime Signature ---\n');
fprintf('Mean ICG variance: %.6f\n', mean(var_ICG));
fprintf('Maximum ICG variance: %.6f\n', max(var_ICG));
fprintf('Mean ICG derivative: %.6f\n', mean(dICG_dt));
fprintf('Maximum ICG derivative: %.6f\n', max(dICG_dt));
fprintf('Minimum ICG derivative: %.6f\n', min(dICG_dt));
fprintf('Global temporal entropy of ICG: %.4f\n', H_temporal_global);
fprintf('Mean temporal entropy: %.4f\n', mean(H_temporal_series));
fprintf('==========================================\n\n');

cd .. % No final volta pra pasta principal

% Função auxiliar local para calcular entropia temporal
function H_temporal = calcular_entropia_temporal_local(ICG, num_bins)
    if nargin < 2
        num_bins = 20;
    end
    
    if isempty(ICG) || length(ICG) < 2
        H_temporal = 0;
        return;
    end
    
    % Normalizar ICG entre 0 e 1
    ICG_normalizado = ICG;
    ICG_min = min(ICG);
    ICG_max = max(ICG);
    if ICG_max > ICG_min
        ICG_normalizado = (ICG - ICG_min) / (ICG_max - ICG_min);
    end
    
    % Discretizar ICG em bins
    edges = linspace(0, 1, num_bins + 1);
    counts = histcounts(ICG_normalizado, edges);
    
    % Calcular distribuição de probabilidade
    total = sum(counts);
    if total > 0
        p = counts / total;
        % Remover zeros para evitar log(0)
        p(p == 0) = [];
        % Calcular entropia de Shannon (base 2)
        if ~isempty(p)
            H_temporal = -sum(p .* log2(p));
        else
            H_temporal = 0;
        end
    else
        H_temporal = 0;
    end
end

% Função auxiliar local para calcular entropia temporal em série
function H_series = calcular_entropia_temporal_series_local(ICG, num_bins, janela_size)
    if nargin < 2
        num_bins = 20;
    end
    if nargin < 3
        janela_size = max(round(length(ICG)/10), 10);
    end
    
    if isempty(ICG) || length(ICG) < 2
        H_series = 0;
        return;
    end
    
    janela_size = min(janela_size, length(ICG));
    N_janelas = length(ICG) - janela_size + 1;
    H_series = zeros(1, N_janelas);
    
    for i = 1:N_janelas
        janela = ICG(i:(i + janela_size - 1));
        H_series(i) = calcular_entropia_temporal_local(janela, num_bins);
    end
end


