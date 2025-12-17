function varargout = Coerencia_Dinamica(varargin)
% COERENCIA_DINAMICA MATLAB code for Coerencia_Dinamica.fig
%      COERENCIA_DINAMICA, by itself, creates a new COERENCIA_DINAMICA or raises the existing
%      singleton*.
%
%      H = COERENCIA_DINAMICA returns the handle to a new COERENCIA_DINAMICA or the handle to
%      the existing singleton*.
%
%      COERENCIA_DINAMICA('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in COERENCIA_DINAMICA.M with the given input arguments.
%
%      COERENCIA_DINAMICA('Property','Value',...) creates a new COERENCIA_DINAMICA or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Coerencia_Dinamica_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Coerencia_Dinamica_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Coerencia_Dinamica

% Last Modified by GUIDE v2.5 16-Dec-2025
% Compatível com MATLAB R2025a e versões anteriores

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Coerencia_Dinamica_OpeningFcn, ...
    'gui_OutputFcn',  @Coerencia_Dinamica_OutputFcn, ...
    'gui_LayoutFcn',  [] , ...
    'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before Coerencia_Dinamica is made visible.
function Coerencia_Dinamica_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Coerencia_Dinamica (see VARARGIN)

% Choose default command line output for Coerencia_Dinamica
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

global tempo terminais_frequencia terminais_dados_sp terminais_qtde selecao terminal_nome taxa_amos

% Verificar se há dados de frequência (terminais_frequencia OU terminais_dados_sp)
dados_freq_disponiveis = false;
if exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia) && sum(terminais_frequencia(:)) ~= 0
    dados_freq_disponiveis = true;
elseif exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp) && size(terminais_dados_sp, 3) >= 5
    dados_freq_disponiveis = true;
end

if ~dados_freq_disponiveis
    warndlg('This method requires PMU frequency data. Load a query with terminais_frequencia or terminais_dados_sp.', 'Warning');
    cd('..');
    set(medfasee,'Visible','on');
    delete(hObject);
    return;
end

% Verificar se há pelo menos 2 PMUs selecionadas
pmus_selecionadas = find(selecao == 1);
if length(pmus_selecionadas) < 2
    warndlg('This method requires at least 2 selected PMUs to calculate coherence.', 'Warning');
    cd('..');
    set(medfasee,'Visible','on');
    delete(hObject);
    return;
end

% Escrever informações iniciais
set(handles.text2,'String', sprintf('Dynamic Coherence - %d PMUs selected', length(pmus_selecionadas)));
set(handles.edit1,'String', num2str(tempo(1)));
set(handles.edit2,'String', num2str(tempo(length(tempo))));
set(handles.edit3,'String', '1');
set(handles.edit4,'String', num2str(length(tempo)));
set(handles.edit5,'String', '10'); % Janela temporal padrão (amostras)
set(handles.edit6,'String', '0.1'); % Frequência mínima do filtro (Hz)
set(handles.edit7,'String', '2.0'); % Frequência máxima do filtro (Hz)

% Parâmetros adicionais para assinatura de regime (se existirem na GUI)
% Nota: Estes campos precisam ser adicionados manualmente no GUIDE
% Se não existirem, serão usados valores padrão
if isfield(handles, 'edit8')
    janela_var_padrao = round(10 * taxa_amos / 2); % Metade da janela temporal
    set(handles.edit8,'String', num2str(janela_var_padrao)); % Janela de variância
end
if isfield(handles, 'edit9')
    set(handles.edit9,'String', '20'); % Número de bins para entropia temporal
end

% UIWAIT makes Coerencia_Dinamica wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Coerencia_Dinamica_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit1_Callback(hObject, eventdata, handles)
global tempo
aux = str2double(get(hObject,'String'));
if isnan(aux) || aux > str2double(get(handles.edit2,'String')) || aux < tempo(1)
    aux = tempo(1);
    set(hObject,'String', num2str(aux));
end
aux1 = find(tempo >= aux, 1);
if isempty(aux1), aux1 = 1; end
set(handles.edit3,'String', num2str(aux1));

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit2_Callback(hObject, eventdata, handles)
global tempo
aux = str2double(get(hObject,'String'));
if isnan(aux) || aux < str2double(get(handles.edit1,'String')) || aux > tempo(length(tempo))
    aux = tempo(length(tempo));
    set(hObject,'String', num2str(aux));
end
aux1 = find(tempo <= aux, 1, 'last');
if isempty(aux1), aux1 = length(tempo); end
set(handles.edit4,'String', num2str(aux1));

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit3_Callback(hObject, eventdata, handles)
global tempo
aux = str2double(get(hObject,'String'));
if isnan(aux) || aux > str2double(get(handles.edit4,'String')) || aux < 1
    aux = 1;
    set(hObject,'String', num2str(aux));
end
if aux > length(tempo), aux = length(tempo); end
if aux < 1, aux = 1; end
set(handles.edit1,'String', num2str(tempo(aux)));

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
global tempo
aux = str2double(get(hObject,'String'));
if isnan(aux) || aux < str2double(get(handles.edit3,'String')) || aux > length(tempo)
    aux = length(tempo);
    set(hObject,'String', num2str(aux));
end
if aux < 1, aux = 1; end
if aux > length(tempo), aux = length(tempo); end
set(handles.edit2,'String', num2str(tempo(aux)));

% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit5_Callback(hObject, eventdata, handles)
% Janela temporal para cálculo de coerência (em amostras)

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit6_Callback(hObject, eventdata, handles)
% Frequência mínima do filtro passa-banda (Hz)

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit7_Callback(hObject, eventdata, handles)
% Frequência máxima do filtro passa-banda (Hz)

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% Calcular e plotar Coerência Dinâmica
global terminais_frequencia terminais_dados_sp terminais_qtde selecao tempo terminal_nome taxa_amos fator_tempo tempo_legenda

% Obter dados de frequência - tentar terminais_frequencia primeiro, depois terminais_dados_sp
if exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia) && sum(terminais_frequencia(:)) ~= 0
    freq_dados = terminais_frequencia;
elseif exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp) && size(terminais_dados_sp, 3) >= 5
    freq_dados = terminais_dados_sp(:,:,5);
else
    warndlg('Frequency data not available.', 'Error');
    return;
end

% Obter parâmetros (usando str2double para compatibilidade MATLAB 2025)
t1 = str2double(get(handles.edit3,'String'));
t2 = str2double(get(handles.edit4,'String'));
janela_temporal = str2double(get(handles.edit5,'String'));
freq_min = str2double(get(handles.edit6,'String'));
freq_max = str2double(get(handles.edit7,'String'));

% Parâmetros adicionais para assinatura de regime (valores padrão se não existirem)
if isfield(handles, 'edit8')
    janela_variancia = str2double(get(handles.edit8,'String'));
    if isnan(janela_variancia) || janela_variancia < 3
        janela_variancia = round(janela_temporal / 2);
    end
else
    janela_variancia = round(janela_temporal / 2); % Padrão: metade da janela temporal
end

if isfield(handles, 'edit9')
    num_bins_entropia = str2double(get(handles.edit9,'String'));
    if isnan(num_bins_entropia) || num_bins_entropia < 5
        num_bins_entropia = 20;
    end
else
    num_bins_entropia = 20; % Padrão: 20 bins
end

% Validar entradas numéricas
if any(isnan([t1, t2, janela_temporal, freq_min, freq_max]))
    warndlg('Please enter valid numeric values in all required fields.', 'Error');
    return;
end

% Validar parâmetros
if t2 - t1 < janela_temporal
    warndlg('The temporal window must be smaller than the selected interval.', 'Warning');
    return;
end

% Obter PMUs selecionadas
pmus_selecionadas = find(selecao == 1);
N = length(pmus_selecionadas);

if N < 2
    warndlg('Select at least 2 PMUs.', 'Warning');
    return;
end

% Extrair dados de frequência das PMUs selecionadas no intervalo
dados_freq = freq_dados(pmus_selecionadas, t1:t2);
tempo_intervalo = tempo(t1:t2) / fator_tempo;
% Guardar tempo original (SOC) para tooltip
tempo_original_soc = tempo(t1:t2);

% Calcular coerência dinâmica, ICG, entropia e métricas da assinatura de regime
% Passar parâmetros adicionais para a função
[ICG, H_entropia, C_matriz, var_ICG, dICG_dt, H_temporal_ICG] = calcular_coerencia_dinamica(dados_freq, tempo_intervalo, janela_temporal, taxa_amos, freq_min, freq_max, janela_variancia, num_bins_entropia);

% Preparar vetor de tempo para as métricas (mesmo tamanho que ICG)
tempo_icg = tempo_intervalo(1:min(length(tempo_intervalo), length(ICG)));
tempo_original_icg = tempo_original_soc(1:min(length(tempo_original_soc), length(ICG)));

% Plotar resultados - Assinatura de Regime Completa
figure('Name', 'Dynamic Coherence - Regime Signature', 'Position', [50 50 1400 900]);

% Subplot 1: ICG vs time
subplot(3,3,1);
plot(tempo_icg, ICG, 'b-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('Global Coherence Index (ICG)');
title('ICG vs Time');
ylim([0 1]);

% Subplot 2: Spatial entropy vs time
subplot(3,3,2);
plot(tempo_icg(1:length(H_entropia)), H_entropia, 'r-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('Spatial Entropy H(t)');
title('Spatial Coherence Entropy');

% Subplot 3: ICG variance vs time
subplot(3,3,3);
plot(tempo_icg, var_ICG, 'g-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('ICG Variance');
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
% Temporal entropy is a scalar value, but we can plot it as a constant
% or calculate it in sliding windows for temporal analysis
H_temporal_series = calcular_entropia_temporal_series(ICG, num_bins_entropia, round(length(ICG)/10));
tempo_entropia = tempo_icg(1:length(H_temporal_series));
plot(tempo_entropia, H_temporal_series, 'c-', 'LineWidth', 2);
grid on;
xlabel(tempo_legenda);
ylabel('Temporal Entropy of ICG');
title('Temporal Entropy of ICG');

% Subplot 6: Mean coherence matrix
subplot(3,3,6);
C_media = mean(C_matriz, 3); % Temporal mean
imagesc(C_media);
colorbar;
colormap('jet');
xlabel('PMU j');
ylabel('PMU i');
title('Coherence Matrix (Mean)');
axis square;

% Subplot 7: ICG and Variance overlaid
subplot(3,3,7);
yyaxis left
plot(tempo_icg, ICG, 'b-', 'LineWidth', 2);
ylabel('ICG', 'Color', 'b');
ylim([0 1]);
yyaxis right
plot(tempo_icg, var_ICG, 'g--', 'LineWidth', 1.5);
ylabel('Variance', 'Color', 'g');
xlabel(tempo_legenda);
title('ICG and Variance');
grid on;
legend('ICG', 'Var(ICG)', 'Location', 'best');

% Subplot 8: ICG and Derivative overlaid
subplot(3,3,8);
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

% Subplot 9: Consolidated panel - all normalized metrics
subplot(3,3,9);
% Normalize all metrics for comparison
ICG_norm = (ICG - min(ICG)) / (max(ICG) - min(ICG) + eps);
H_esp_norm = (H_entropia - min(H_entropia)) / (max(H_entropia) - min(H_entropia) + eps);
var_norm = var_ICG / (max(var_ICG) + eps);
dICG_norm = (dICG_dt - min(dICG_dt)) / (max(dICG_dt) - min(dICG_dt) + eps);
H_temp_norm = (H_temporal_series - min(H_temporal_series)) / (max(H_temporal_series) - min(H_temporal_series) + eps);

plot(tempo_icg, ICG_norm, 'b-', 'LineWidth', 1.5); hold on;
plot(tempo_icg(1:length(H_esp_norm)), H_esp_norm, 'r-', 'LineWidth', 1.5);
plot(tempo_icg, var_norm, 'g--', 'LineWidth', 1.5);
plot(tempo_icg, dICG_norm, 'm--', 'LineWidth', 1.5);
plot(tempo_entropia, H_temp_norm, 'c--', 'LineWidth', 1.5);
hold off;
grid on;
xlabel(tempo_legenda);
ylabel('Normalized Values');
title('Regime Signature - All Metrics');
legend('ICG', 'H_{sp}', 'Var(ICG)', 'dICG/dt', 'H_{temp}', 'Location', 'best', 'FontSize', 8);

% Formatar eixo X com tempo relativo e configurar tooltip
if ~exist('formatar_eixo_tempo', 'file')
    addpath(fullfile(fileparts(mfilename('fullpath')), '..', 'graficos'));
end

% Configurar tooltip para todos os subplots
% formatar_eixo_tempo já configura o tooltip automaticamente
for sp = 1:9
    subplot(3,3,sp);
    if exist('formatar_eixo_tempo', 'file')
        formatar_eixo_tempo(tempo_icg, tempo_legenda);
    end
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

% Mostrar informações no console
fprintf('\n=== Dynamic Coherence Analysis Results ===\n');
fprintf('PMUs analyzed: %d\n', N);
fprintf('Time interval: %.2f to %.2f seconds\n', tempo_intervalo(1), tempo_intervalo(end));
fprintf('\n--- Basic Metrics ---\n');
fprintf('Mean ICG: %.4f\n', mean(ICG));
fprintf('Minimum ICG: %.4f\n', min(ICG));
fprintf('Maximum ICG: %.4f\n', max(ICG));
fprintf('Mean spatial entropy: %.4f\n', mean(H_entropia));
fprintf('Maximum spatial entropy: %.4f\n', max(H_entropia));
fprintf('\n--- Regime Signature ---\n');
fprintf('Mean ICG variance: %.6f\n', mean(var_ICG));
fprintf('Maximum ICG variance: %.6f\n', max(var_ICG));
fprintf('Mean ICG derivative: %.6f\n', mean(dICG_dt));
fprintf('Maximum ICG derivative: %.6f\n', max(dICG_dt));
fprintf('Minimum ICG derivative: %.6f\n', min(dICG_dt));
fprintf('Temporal entropy of ICG: %.4f\n', H_temporal_ICG);
fprintf('==================================================\n\n');

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
cd('..');
set(medfasee,'Visible','on');
delete(hObject);

% Função auxiliar para calcular coerência dinâmica
function [ICG, H_entropia, C_matriz, var_ICG, dICG_dt, H_temporal_ICG] = calcular_coerencia_dinamica(dados_freq, tempo_intervalo, janela_temporal, taxa_amos, freq_min, freq_max, janela_variancia, num_bins)
% Calcula coerência dinâmica entre pares de PMUs
% Entrada:
%   dados_freq: matriz [N_PMUs x N_amostras] com dados de frequência
%   tempo_intervalo: vetor de tempo
%   janela_temporal: tamanho da janela deslizante (amostras)
%   taxa_amos: taxa de amostragem (Hz)
%   freq_min, freq_max: frequências do filtro passa-banda (Hz)
% Saída:
%   ICG: Índice de Coerência Global ao longo do tempo
%   H_entropia: Entropia de Coerência Espacial ao longo do tempo
%   C_matriz: Matriz de coerência [N x N x N_janelas]
%   var_ICG: Variância do ICG em janelas deslizantes
%   dICG_dt: Derivada temporal do ICG
%   H_temporal_ICG: Entropia temporal do ICG

[N_pmus, N_amostras] = size(dados_freq);

% Aplicar filtro passa-banda se especificado
if freq_min > 0 && freq_max > 0 && freq_max > freq_min
    % Criar filtro passa-banda Butterworth
    [b, a] = butter(4, [freq_min freq_max]/(taxa_amos/2), 'bandpass');
    for i = 1:N_pmus
        dados_freq(i,:) = filtfilt(b, a, dados_freq(i,:));
    end
end

% Calcular número de janelas
N_janelas = N_amostras - janela_temporal + 1;
if N_janelas < 1
    N_janelas = 1;
    janela_temporal = N_amostras;
end

% Inicializar matrizes
C_matriz = zeros(N_pmus, N_pmus, N_janelas);
ICG = zeros(1, N_janelas);
H_entropia = zeros(1, N_janelas);

% Calcular coerência para cada janela temporal
for t = 1:N_janelas
    janela = t:(t + janela_temporal - 1);
    dados_janela = dados_freq(:, janela);
    
    % Calcular matriz de coerência para esta janela
    C_janela = zeros(N_pmus, N_pmus);
    for i = 1:N_pmus
        for j = 1:N_pmus
            if i == j
                C_janela(i,j) = 1.0; % Coerência consigo mesmo = 1
            else
                % Calcular coerência usando correlação normalizada
                % e análise espectral
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
    
    C_matriz(:,:,t) = C_janela;
    
    % Calcular ICG (média de todas as arestas, excluindo diagonal)
    indices_triang_superior = triu(ones(N_pmus), 1) == 1;
    C_arestas = C_janela(indices_triang_superior);
    ICG(t) = mean(C_arestas);
    
    % Calcular entropia de coerência espacial
    % Normalizar arestas
    soma_arestas = sum(C_arestas);
    if soma_arestas > 0
        p_arestas = C_arestas / soma_arestas;
        % Calcular entropia (evitar log(0))
        p_arestas(p_arestas == 0) = eps;
        H_entropia(t) = -sum(p_arestas .* log(p_arestas));
    else
        H_entropia(t) = 0;
    end
end

% Calcular métricas adicionais da assinatura de regime
% Variância do ICG em janelas deslizantes
if nargin < 7 || isempty(janela_variancia)
    janela_variancia = round(janela_temporal/2);
end
if nargin < 8 || isempty(num_bins)
    num_bins = 20;
end
janela_var = min(max(round(janela_variancia), 3), length(ICG));
if length(ICG) > 1
    % Usar movvar se disponível (MATLAB R2016a+), senão calcular manualmente
    if exist('movvar', 'builtin') || exist('movvar', 'file')
        var_ICG = movvar(ICG, janela_var);
    else
        % Implementação manual de variância em janela deslizante
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
if length(tempo_intervalo) > 1 && N_janelas > 1
    % Calcular intervalo temporal médio entre janelas
    tempo_icg = tempo_intervalo(1:min(length(tempo_intervalo), N_janelas));
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
else
    dICG_dt = zeros(size(ICG));
end

% Entropia temporal do ICG
H_temporal_ICG = calcular_entropia_temporal(ICG, num_bins);
end

% Função auxiliar para calcular entropia temporal do ICG
function H_temporal = calcular_entropia_temporal(ICG, num_bins)
    % Calcula entropia temporal do ICG usando histograma
    % ICG: série temporal do índice de coerência global
    % num_bins: número de bins para discretização (padrão: 20)
    % Retorna: entropia de Shannon da distribuição temporal
    
    if nargin < 2
        num_bins = 20;
    end
    
    if isempty(ICG) || length(ICG) < 2
        H_temporal = 0;
        return;
    end
    
    % Garantir que ICG está entre 0 e 1
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

% Função auxiliar para calcular entropia temporal em série (janelas deslizantes)
function H_series = calcular_entropia_temporal_series(ICG, num_bins, janela_size)
    % Calcula entropia temporal do ICG em janelas deslizantes
    % ICG: série temporal do índice de coerência global
    % num_bins: número de bins para discretização
    % janela_size: tamanho da janela deslizante
    % Retorna: série temporal de entropia
    
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
        H_series(i) = calcular_entropia_temporal(janela, num_bins);
    end
end

