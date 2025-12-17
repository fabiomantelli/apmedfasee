function varargout = medfasee(varargin)
% MEDFASEE MATLAB code for medfasee.fig
% Compatível com MATLAB R2025a e versões anteriores
% Última atualização: Dezembro 2025
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @medfasee_OpeningFcn, ...
                   'gui_OutputFcn',  @medfasee_OutputFcn, ...
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
end

%% --- Executes just before medfasee is made visible.
function medfasee_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);

% Salvar diretório raiz para compatibilidade MATLAB 2025
% Usar o diretório onde o medfasee.m está localizado, não o pwd atual
[arquivo_path, ~, ~] = fileparts(mfilename('fullpath'));
dir_raiz = arquivo_path;
handles.dir_raiz = dir_raiz;
guidata(hObject, handles);

% Mudar para o diretório raiz para garantir que estamos no lugar certo
cd(dir_raiz);

% --- Carrega consultas (usando caminhos relativos - compatível com MATLAB 2025)
dir_consultas = fullfile(dir_raiz, 'consultas');
if exist(dir_consultas, 'dir')
    aux1 = dir(fullfile(dir_consultas, '*.mat'));
    if ~isempty(aux1)
        casos_exist = {aux1.name};
        set(handles.listbox1, 'String', casos_exist);
        set(handles.listbox1, 'Value', 1);
    else
        set(handles.listbox1, 'String', {});
    end
else
    set(handles.listbox1, 'String', {});
end

% --- Carrega grficos
dir_graficos = fullfile(dir_raiz, 'graficos');
if exist(dir_graficos, 'dir')
    aux2 = dir(fullfile(dir_graficos, '*.m'));
    graf_exist = {aux2.name};
    if ~isempty(graf_exist)
        set(handles.listbox3, 'String', graf_exist);
    end
end

% --- Carrega mtodos 
dir_metodos = fullfile(dir_raiz, 'metodos');
if exist(dir_metodos, 'dir')
    aux3 = dir(fullfile(dir_metodos, '*.m'));
    met_exist = {aux3.name};
    % Filtrar para remover arquivos que não são métodos (se houver)
    % e garantir que Coerencia_Dinamica.m está incluído
    if ~isempty(met_exist)
        set(handles.listbox4, 'String', met_exist);
    end
end
end

%% --- Outputs from this function are returned to the command line.
function varargout = medfasee_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;
end

%% --- CreateFcn para todos os listboxes e popupmenu
function listbox1_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
end

function listbox2_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
end

function listbox3_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
end

function listbox4_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
end

function popupmenu1_CreateFcn(hObject, eventdata, handles)
set(hObject,'BackgroundColor','white');
end

%% --- Callbacks
function listbox1_Callback(hObject, eventdata, handles)
clear global SPMS_nome base_modulo taxa_amos tempo_legenda terminais_dados terminais_dados_s0 terminais_dados_sn terminais_dados_sp terminais_qtde terminal_nome terminais_frequencia dados_nome ref_sel fator_tempo tempo tem_corrente selecao;
end

function listbox2_Callback(hObject, eventdata, handles)
global selecao terminais_qtde
selecao = zeros(1,terminais_qtde);
aux = get(hObject,'Value');
selecao(aux) = 1;
set(handles.listbox3,'Enable','on');
set(handles.pushbutton4,'Enable','on');
end

function popupmenu1_Callback(hObject, eventdata, handles)
global ref_sel
ref_sel = get(hObject,'Value');
end

function listbox3_Callback(hObject, eventdata, handles)
global graf_sel aux_graf
aux_graf = get(hObject,'Value');
graf_sel_cell = get(hObject,'String');
% Converter cell array para matriz de caracteres (como terminal_nome)
if ~isempty(graf_sel_cell)
    graf_sel = char(graf_sel_cell);
else
    graf_sel = [];
end
end

function pushbutton1_Callback(hObject, eventdata, handles)
global SPMS_nome base_modulo taxa_amos tempo_legenda terminais_dados ...
    terminais_dados_s0 terminais_dados_sn terminais_dados_sp ...
    terminais_qtde terminal_nome terminais_frequencia dados_nome ...
    ref_sel fator_tempo tempo tem_corrente selecao terminais_cor tempo_soc_original

% Obter arquivo selecionado no listbox1
lista_consultas = get(handles.listbox1, 'String');
indice_selecionado = get(handles.listbox1, 'Value');

if isempty(lista_consultas) || indice_selecionado == 0
    warndlg('Selecione uma consulta primeiro', 'Aviso');
    return;
end

nome_arquivo = lista_consultas{indice_selecionado};

% Carregar arquivo .mat da pasta consultas (compatível com MATLAB 2025)
dir_raiz = pwd;
if isfield(handles, 'dir_raiz')
    dir_raiz = handles.dir_raiz;
end
dir_consultas = fullfile(dir_raiz, 'consultas');
caminho_arquivo = fullfile(dir_consultas, nome_arquivo);

try
    if exist(caminho_arquivo, 'file')
        load(caminho_arquivo);
    else
        warndlg(['Arquivo não encontrado: ' nome_arquivo], 'Erro');
        return;
    end
catch ME
    warndlg(['Erro ao carregar arquivo: ' ME.message], 'Erro');
    return;
end

% Verificar se terminal_nome existe
if ~exist('terminal_nome', 'var') || ~exist('terminais_qtde', 'var')
    warndlg('Arquivo não contém dados de terminais válidos', 'Erro');
    return;
end

% Converter terminal_nome (matriz de caracteres) para cell array
nomes_pmus = cellstr(terminal_nome);

% Popular listbox2 com os nomes dos terminais
set(handles.listbox2, 'String', nomes_pmus);
set(handles.listbox2, 'Value', 1);
set(handles.listbox2, 'Enable', 'on');

% Atualizar popupmenu1 (referência) com os terminais
set(handles.popupmenu1, 'String', nomes_pmus);
set(handles.popupmenu1, 'Value', 1);
ref_sel = 1;

% Inicializar selecao
selecao = zeros(1, terminais_qtde);

% Preparar variáveis de tempo se necessário
% O tempo deve ser baseado no tamanho real dos dados
% Verificar primeiro se terminais_dados existe e tem dados válidos
if exist('terminais_dados', 'var') && ~isempty(terminais_dados)
    % Encontrar o tamanho mínimo comum entre todos os terminais
    % (alguns podem ter tamanhos diferentes devido a dados faltantes)
    tamanhos = zeros(1, terminais_qtde);
    for i = 1:terminais_qtde
        % Contar quantos dados válidos existem (não NaN, não zero)
        dados_validos = terminais_dados(i, :, 1);
        dados_validos = dados_validos(~isnan(dados_validos) & dados_validos ~= 0);
        if ~isempty(dados_validos)
            tamanhos(i) = length(dados_validos);
        else
            tamanhos(i) = size(terminais_dados, 2);
        end
    end
    % Usar o tamanho mínimo para garantir compatibilidade
    tamanho_dados = min(tamanhos(tamanhos > 0));
    if isempty(tamanho_dados)
        tamanho_dados = size(terminais_dados, 2);
    end
    
    if tamanho_dados > 0
        % Usar o tempo do primeiro terminal como base, limitado ao tamanho mínimo
        tempo_soc = terminais_dados(1, 1:tamanho_dados, 1);
        
        % Armazenar SOC original para tooltip mostrar hora real
        tempo_soc_original = tempo_soc;
        
        % Converter SOC (Unix timestamp) para tempo relativo em segundos desde o início
        if ~isempty(tempo_soc) && all(tempo_soc > 0) && max(tempo_soc) > 1e9
            tempo_inicial = tempo_soc(1); % Primeiro SOC (início da gravação)
            tempo = tempo_soc - tempo_inicial; % Tempo relativo em segundos
        else
            tempo = tempo_soc;
            tempo_soc_original = tempo_soc; % Mesmo valor se não for SOC
        end
        
        fator_tempo = 1;
    end
elseif exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp)
    % Se não tem terminais_dados, tentar usar terminais_dados_sp
    tamanho_dados = size(terminais_dados_sp, 2);
    if tamanho_dados > 0
        % Tentar obter tempo de terminais_dados se ainda existir
        if exist('terminais_dados', 'var') && ~isempty(terminais_dados)
            tamanho_terminais = size(terminais_dados, 2);
            if tamanho_terminais >= tamanho_dados
                tempo_soc = terminais_dados(1, 1:tamanho_dados, 1);
                
                % Armazenar SOC original para tooltip mostrar hora real
                tempo_soc_original = tempo_soc;
                
                % Converter SOC (Unix timestamp) para tempo relativo em segundos desde o início
                if ~isempty(tempo_soc) && all(tempo_soc > 0) && max(tempo_soc) > 1e9
                    tempo_inicial = tempo_soc(1); % Primeiro SOC (início da gravação)
                    tempo = tempo_soc - tempo_inicial; % Tempo relativo em segundos
                else
                    tempo = tempo_soc;
                    tempo_soc_original = tempo_soc; % Mesmo valor se não for SOC
                end
            else
                % Criar tempo baseado no índice
                if exist('taxa_amos', 'var') && ~isempty(taxa_amos) && taxa_amos > 0
                    tempo = (0:(tamanho_dados-1)) / taxa_amos;
                else
                    tempo = 0:(tamanho_dados-1);
                end
            end
        else
            % Criar tempo baseado no índice e taxa de amostragem
            if exist('taxa_amos', 'var') && ~isempty(taxa_amos) && taxa_amos > 0
                tempo = (0:(tamanho_dados-1)) / taxa_amos;
            else
                tempo = 0:(tamanho_dados-1);
            end
        end
        fator_tempo = 1;
    end
end

% Inicializar terminais_cor se não existir
if ~exist('terminais_cor', 'var') || isempty(terminais_cor)
    % Carregar tabela de cores (compatível com MATLAB 2025)
    dir_raiz = pwd;
    if isfield(handles, 'dir_raiz')
        dir_raiz = handles.dir_raiz;
    end
    dir_consultas = fullfile(dir_raiz, 'consultas');
    caminho_tab_cor = fullfile(dir_consultas, 'tab_cor.m');
    if exist(caminho_tab_cor, 'file')
        % Adicionar ao path temporariamente
        addpath(dir_consultas);
        tab_cor;
        rmpath(dir_consultas);
    else
        % Se tab_cor.m não existir, criar terminais_cor padrão
        terminais_cor = [
            '[1.00 0.00 1.00]'  % Magenta
            '[0.00 0.75 1.00]'  % ciano
            '[1.00 0.50 0.00]'  % Laranja
            '[1.00 0.00 0.00]'  % Vermelho normal 
            '[0.70 0.00 0.00]'  % Vermelho Escuro
            '[0.50 0.00 0.70]'  % Roxo
            '[0.75 0.75 0.00]'  % amarelo queimado
            '[0.00 1.00 0.00]'  % Verde
            '[0.00 0.00 1.00]'  % Azul
            '[0.00 0.00 0.00]'  % Preto
            '[0.75 0.00 0.75]'  % magenta escuro
            '[0.80 0.80 0.80]'  % Cinza
            '[0.85 0.70 1.00]'  % magenta escuro
            '[0.00 0.80 0.00]'  % Verde 80%
            '[0.00 0.40 0.00]'  % Verde
        ];
    end
end

% Garantir que terminais_cor tem pelo menos terminais_qtde linhas
if size(terminais_cor, 1) < terminais_qtde
    % Repetir cores se necessário
    cores_base = terminais_cor;
    num_repeticoes = ceil(terminais_qtde / size(cores_base, 1));
    terminais_cor = repmat(cores_base, num_repeticoes, 1);
    terminais_cor = terminais_cor(1:terminais_qtde, :);
end

% Filtrar gráficos disponíveis baseado nos dados carregados
% IMPORTANTE: Garantir que terminais_frequencia está disponível globalmente
% antes de filtrar
if exist('terminais_frequencia', 'var')
    % Variável já está no workspace, apenas garantir que é global
    global terminais_frequencia;
else
    % Se não existe, inicializar como vazia
    terminais_frequencia = [];
end

filtrar_graficos_disponiveis(handles);

guidata(hObject, handles);
end

function pushbutton2_Callback(hObject, eventdata, handles)
% Abre interface para criar nova consulta (importar dados e gerar .mat)
% Compatível com MATLAB 2025

% Declarar variáveis globais ANTES de qualquer uso (compatível com MATLAB 2025)
global dir_raiz dir_dat ArmazenaResult tempo_legenda

% Salvar diretório raiz
dir_raiz_local = pwd;
if isfield(handles, 'dir_raiz')
    dir_raiz_local = handles.dir_raiz;
end

% Atribuir ao global após determinar o valor
dir_raiz = dir_raiz_local;

% Adicionar pasta consultas ao path se necessário
dir_consultas = fullfile(dir_raiz, 'consultas');
if exist(dir_consultas, 'dir')
    if ~contains(path, dir_consultas)
        addpath(dir_consultas);
    end
    
    % Inicializar outras variáveis globais necessárias para leitura.m
    tempo_legenda = 'Tempo (s)'; % Valor padrão
    % dir_dat será solicitado pelo def_arq quando o usuário clicar em processar
    
    % Mudar para pasta consultas temporariamente
    cd(dir_consultas);
    
    % Abrir interface def_arq para criar nova consulta
    try
        def_arq;
    catch ME
        cd(dir_raiz);
        warndlg(['Erro ao abrir interface de importação: ' ME.message], 'Erro');
    end
else
    warndlg('Pasta "consultas" não encontrada!', 'Erro');
end
end

function pushbutton3_Callback(hObject, eventdata, handles)
% Lgica de exporta_comtrade
end

function pushbutton4_Callback(hObject, eventdata, handles)
global selecao terminais_qtde graf_sel aux_graf

% Verificar se há seleção de PMUs
if ~exist('selecao', 'var') || sum(selecao) == 0
    warndlg('Selecione pelo menos uma PMU primeiro', 'Aviso');
    return;
end

% Obter seleção diretamente do listbox3 para garantir que está atualizado
lista_graf = get(handles.listbox3, 'String');
indice_graf = get(handles.listbox3, 'Value');

% Verificar se há gráfico selecionado
if isempty(lista_graf) || isempty(indice_graf) || indice_graf == 0
    warndlg('Selecione um gráfico primeiro', 'Aviso');
    return;
end

% Garantir que indice_graf é um escalar (pegar primeiro se for vetor)
if length(indice_graf) > 1
    indice_graf = indice_graf(1);
end

% Verificar se o índice está dentro dos limites
if indice_graf > length(lista_graf)
    warndlg('Índice de gráfico inválido', 'Erro');
    return;
end

% Obter nome do gráfico selecionado
nome_grafico = lista_graf{indice_graf};

% Remover extensão .m se presente
if length(nome_grafico) > 2 && strcmp(nome_grafico(end-1:end), '.m')
    nome_grafico = nome_grafico(1:end-2);
end

% Atualizar variáveis globais para compatibilidade com outros códigos
if ~isempty(lista_graf)
    graf_sel = char(lista_graf);
    aux_graf = indice_graf;
end

% Ajustar tempo para o tamanho correto baseado nos dados que serão usados
ajustar_tempo_para_grafico(nome_grafico);

% Verificar e garantir que tempo tem o tamanho correto dos dados
% Isso evita erros de incompatibilidade de tamanhos nos scripts
global tempo terminais_dados terminais_dados_sp terminais_dados_sn terminais_dados_s0 terminais_frequencia taxa_amos

% Determinar qual fonte de dados será usada e verificar tamanho
tamanho_esperado = [];
if contains(nome_grafico, 'freq_pmu')
    if exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia)
        tamanho_esperado = size(terminais_frequencia, 2);
    end
elseif contains(nome_grafico, 'seq_pos') || contains(nome_grafico, 'seq_neg') || ...
       contains(nome_grafico, 'seq_zero') || contains(nome_grafico, 'freq_calc') || ...
       contains(nome_grafico, 'freq_filt') || contains(nome_grafico, 'freq_FK') || ...
       contains(nome_grafico, 'freq_oob') || contains(nome_grafico, 'oscil') || ...
       contains(nome_grafico, 'rocof') || contains(nome_grafico, 'rocov') || ...
       contains(nome_grafico, 'taxa_freq') || contains(nome_grafico, 'dif_angular') || ...
       contains(nome_grafico, 'ind_deseq')
    if contains(nome_grafico, 'seq_pos') || contains(nome_grafico, 'freq_calc') || ...
       contains(nome_grafico, 'freq_filt') || contains(nome_grafico, 'freq_FK') || ...
       contains(nome_grafico, 'freq_oob') || contains(nome_grafico, 'oscil') || ...
       contains(nome_grafico, 'rocof') || contains(nome_grafico, 'rocov') || ...
       contains(nome_grafico, 'taxa_freq') || contains(nome_grafico, 'dif_angular')
        if exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp)
            tamanho_esperado = size(terminais_dados_sp, 2);
        end
    elseif contains(nome_grafico, 'seq_neg') || contains(nome_grafico, 'ind_deseq')
        if exist('terminais_dados_sn', 'var') && ~isempty(terminais_dados_sn)
            tamanho_esperado = size(terminais_dados_sn, 2);
        end
    else
        if exist('terminais_dados_s0', 'var') && ~isempty(terminais_dados_s0)
            tamanho_esperado = size(terminais_dados_s0, 2);
        end
    end
else
    if exist('terminais_dados', 'var') && ~isempty(terminais_dados)
        tamanho_esperado = size(terminais_dados, 2);
    end
end

% Garantir que tempo tem o tamanho correto
global tempo_soc_original
if ~isempty(tamanho_esperado) && exist('tempo', 'var')
    if length(tempo) ~= tamanho_esperado
        % Ajustar tempo para o tamanho correto
        if exist('terminais_dados', 'var') && ~isempty(terminais_dados) && size(terminais_dados, 2) >= tamanho_esperado
            tempo_soc_temp = terminais_dados(1, 1:tamanho_esperado, 1);
            % Armazenar SOC original
            tempo_soc_original = tempo_soc_temp;
            % Converter para relativo se for SOC
            if ~isempty(tempo_soc_temp) && all(tempo_soc_temp > 0) && max(tempo_soc_temp) > 1e9
                tempo_inicial = tempo_soc_temp(1);
                tempo = tempo_soc_temp - tempo_inicial;
            else
                tempo = tempo_soc_temp;
                tempo_soc_original = tempo_soc_temp;
            end
        elseif exist('taxa_amos', 'var') && ~isempty(taxa_amos) && taxa_amos > 0
            tempo = (0:(tamanho_esperado-1)) / taxa_amos;
            tempo_soc_original = []; % Não há SOC neste caso
        else
            tempo = 0:(tamanho_esperado-1);
            tempo_soc_original = []; % Não há SOC neste caso
        end
    end
end

% Salvar diretório atual (raiz do projeto)
dir_raiz = pwd;

% Adicionar diretório raiz ao path do MATLAB para garantir que medfasee seja encontrado
addpath(dir_raiz);

% Limpar variável sinal para evitar problemas de inicialização
% Isso garante que sinal será inicializado com o tamanho correto no script
clear sinal;

% Executar script do gráfico (compatível com MATLAB 2025)
dir_graficos = fullfile(dir_raiz, 'graficos');
if ~contains(path, dir_graficos)
    addpath(dir_graficos);
end
cd(dir_graficos);
try
    % Debug: verificar e corrigir tamanhos antes de executar
    global tempo terminais_dados terminais_qtde selecao sinal
    % Limpar sinal (variável global) para evitar problemas de inicialização
    % Isso garante que sinal será inicializado com o tamanho correto no script
    % quando o script fizer sinal(i,:) = terminais_dados(i,:,2)
    sinal = [];
    
    if exist('terminais_dados', 'var') && ~isempty(terminais_dados)
        tamanho_dados = size(terminais_dados, 2);
        if exist('tempo', 'var') && ~isempty(tempo)
            tamanho_tempo = length(tempo);
            if tamanho_tempo ~= tamanho_dados
                % Corrigir tempo para ter exatamente o tamanho dos dados
                tempo_soc_temp = terminais_dados(1, 1:tamanho_dados, 1);
                % Armazenar SOC original
                tempo_soc_original = tempo_soc_temp;
                % Converter para relativo se for SOC
                if ~isempty(tempo_soc_temp) && all(tempo_soc_temp > 0) && max(tempo_soc_temp) > 1e9
                    tempo_inicial = tempo_soc_temp(1);
                    tempo = tempo_soc_temp - tempo_inicial;
                else
                    tempo = tempo_soc_temp;
                    tempo_soc_original = tempo_soc_temp;
                end
            end
        else
            % Criar tempo se não existir
            tempo_soc_temp = terminais_dados(1, 1:tamanho_dados, 1);
            % Armazenar SOC original
            tempo_soc_original = tempo_soc_temp;
            % Converter para relativo se for SOC
            if ~isempty(tempo_soc_temp) && all(tempo_soc_temp > 0) && max(tempo_soc_temp) > 1e9
                tempo_inicial = tempo_soc_temp(1);
                tempo = tempo_soc_temp - tempo_inicial;
            else
                tempo = tempo_soc_temp;
                tempo_soc_original = tempo_soc_temp;
            end
        end
    end
    
    eval(nome_grafico);
    % Os scripts de gráfico fazem 'cd ..' no final, mas garantimos que voltamos ao raiz
    if ~strcmp(pwd, dir_raiz)
        cd(dir_raiz);
    end
catch ME
    % Em caso de erro, garantir que voltamos ao diretório raiz
    if ~strcmp(pwd, dir_raiz)
        cd(dir_raiz);
    end
    % Debug: mostrar informações adicionais sobre o erro
    mensagem_erro = ['Erro ao executar gráfico: ' ME.message];
    if exist('terminais_dados', 'var') && ~isempty(terminais_dados)
        mensagem_erro = [mensagem_erro sprintf('\nTamanho terminais_dados: %s', mat2str(size(terminais_dados)))];
    end
    if exist('tempo', 'var') && ~isempty(tempo)
        mensagem_erro = [mensagem_erro sprintf('\nTamanho tempo: %d', length(tempo))];
    end
    if exist('selecao', 'var')
        mensagem_erro = [mensagem_erro sprintf('\nTerminais selecionados: %s', mat2str(find(selecao == 1)))];
    end
    warndlg(mensagem_erro, 'Erro');
end
end

function pushbutton5_Callback(hObject, eventdata, handles)
global aux_met met_sel selecao sinal graf_sel aux_graf ref_sel

aux_met = get(handles.listbox4,'Value');   
met_sel = get(handles.listbox4,'String');  
nome_metodo = cellstr(met_sel(aux_met,:));

% Verificar se é o método de Coerência Dinâmica (precisa de gráfico de frequência plotado)
if strcmp(nome_metodo{1}, 'Coerencia_Dinamica.m')
    % Validação específica para Coerência Dinâmica:
    % - Precisa ter plotado um gráfico de frequência (freq_calc, freq_filt ou freq_oob)
    % - Precisa ter pelo menos 2 PMUs selecionadas
    cond_valida = false;
    
    % Verificar se há pelo menos 2 PMUs selecionadas primeiro
    if exist('selecao', 'var') && sum(selecao) >= 2
        % Verificar se há gráfico plotado - tentar múltiplas formas
        nome_grafico_plotado = '';
        
        % Método 1: Usar graf_sel se disponível
        if exist('graf_sel', 'var') && exist('aux_graf', 'var') && ~isempty(graf_sel) && aux_graf > 0
            if aux_graf <= size(graf_sel, 1)
                nome_grafico_plotado = strtrim(graf_sel(aux_graf,:));
            end
        end
        
        % Método 2: Se não encontrou, tentar obter diretamente do listbox3
        if isempty(nome_grafico_plotado)
            try
                lista_graf_atual = get(handles.listbox3, 'String');
                indice_graf_atual = get(handles.listbox3, 'Value');
                if ~isempty(lista_graf_atual) && indice_graf_atual > 0 && indice_graf_atual <= length(lista_graf_atual)
                    nome_grafico_plotado = lista_graf_atual{indice_graf_atual};
                end
            catch
                % Ignorar erro
            end
        end
        
        % Método 3: Verificar se sinal existe e foi plotado (para gráficos de frequência)
        if isempty(nome_grafico_plotado) && exist('sinal', 'var') && ~isempty(sinal)
            % Se sinal existe, assumir que um gráfico foi plotado
            % Verificar se há dados de frequência disponíveis
            global terminais_frequencia terminais_dados_sp
            if (exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia)) || ...
               (exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp))
                cond_valida = true; % Aceitar se há dados de frequência e 2+ PMUs
            end
        end
        
        % Verificar se é um gráfico de frequência válido
        if ~isempty(nome_grafico_plotado)
            % Remover espaços e garantir formato .m
            nome_grafico_plotado = strtrim(nome_grafico_plotado);
            if length(nome_grafico_plotado) < 2 || ~strcmp(nome_grafico_plotado(end-1:end), '.m')
                nome_grafico_plotado = [nome_grafico_plotado '.m'];
            end
            
            graficos_freq_validos = {'freq_calc.m', 'freq_filt.m', 'freq_oob.m', 'freq_pmu.m'};
            if any(strcmp(nome_grafico_plotado, graficos_freq_validos))
                cond_valida = true;
            end
        end
    end
else
    % Validação padrão para outros métodos (precisam de sinal plotado)
    if exist('sinal', 'var') && ~isempty(sinal)
sinais_validos = sum(sinal,2) ~= 0;
cond1 = sum(selecao(1:length(sinais_validos)) .* sinais_validos') == sum(selecao);
cond2 = (sum(selecao) - sum(selecao(1:length(sinais_validos)) .* (sinal(:,2) ~= 0)')) == 1;
cond3 = strcmp('dif_angular.m', cellstr(graf_sel(aux_graf,:)));
cond4 = selecao(ref_sel) == 1;
        cond_valida = cond1 || (cond2 && cond3 && cond4);
    else
        cond_valida = false;
    end
end

if cond_valida
    set(medfasee,'Visible','off');
    % Usar caminho absoluto para compatibilidade MATLAB 2025
    dir_raiz = pwd;
    if isfield(handles, 'dir_raiz')
        dir_raiz = handles.dir_raiz;
    end
    dir_metodos = fullfile(dir_raiz, 'metodos');
    if ~contains(path, dir_metodos)
        addpath(dir_metodos);
    end
    cd(dir_metodos);
    switch nome_metodo{1}
        case 'DFT.m', DFT;
        case 'DFT_Janelada.m', DFT_Janelada;
        case 'Prony.m', Prony;
        case 'RBE.m', RBE;
        case 'Matrix_Pencil.m'
            if sum(selecao)==1, Matrix_Pencil;
            else cd ..; set(medfasee,'Visible','on'); warndlg('Escolha o sinal de apenas uma PMU','!! Warning !!'); end
        case 'DEW_Mayara.m', DEW_Mayara;
        case 'Coerencia_Dinamica.m'
            % Verificar se há dados de frequência e pelo menos 2 PMUs selecionadas
            global terminais_frequencia terminais_dados_sp terminais_qtde selecao
            % Verificar se há dados de frequência (terminais_frequencia OU terminais_dados_sp)
            tem_freq = false;
            if exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia) && sum(terminais_frequencia(:)) ~= 0
                tem_freq = true;
            elseif exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp) && size(terminais_dados_sp, 3) >= 5
                tem_freq = true;
            end
            
            if ~tem_freq
                cd ..; set(medfasee,'Visible','on'); 
                warndlg('Este método requer dados de frequência das PMUs. Carregue uma consulta com terminais_frequencia ou terminais_dados_sp.', 'Aviso');
            elseif sum(selecao) < 2
                cd ..; set(medfasee,'Visible','on');
                warndlg('Este método requer pelo menos 2 PMUs selecionadas para calcular coerência.', 'Aviso');
            else
                Coerencia_Dinamica;
            end
    end
    else
        if strcmp(nome_metodo{1}, 'Coerencia_Dinamica.m')
            warndlg('Plote um gráfico de frequência (freq_calc, freq_filt ou freq_oob) e selecione pelo menos 2 PMUs antes de usar este método.','!! Warning !!');
        else
            warndlg('Trace o sinal antes de selecionar o Mtodo','!! Warning !!');
        end
    end
end

function checkbox1_Callback(hObject, eventdata, handles)
% lgica checkbox
end

% Função auxiliar para filtrar gráficos disponíveis
function filtrar_graficos_disponiveis(handles)
global terminais_dados terminais_dados_sp terminais_dados_sn terminais_dados_s0 ...
    terminais_frequencia tem_corrente

% Obter lista completa de gráficos
lista_graf_completa = get(handles.listbox3, 'String');
if isempty(lista_graf_completa)
    return;
end

% Verificar quais variáveis estão disponíveis
tem_sequencia = exist('terminais_dados_sp', 'var') && ~isempty(terminais_dados_sp);
tem_sequencia_neg = exist('terminais_dados_sn', 'var') && ~isempty(terminais_dados_sn);
tem_sequencia_zero = exist('terminais_dados_s0', 'var') && ~isempty(terminais_dados_s0);

% Verificar terminais_frequencia de forma mais robusta
tem_freq_pmu = false;
% A variável terminais_frequencia foi declarada como global no início da função
% Verificar se existe e tem dados válidos
try
    if exist('terminais_frequencia', 'var')
        % Verificar se não está vazia
        if ~isempty(terminais_frequencia)
            % Verificar se tem pelo menos alguns valores não-zero
            % Usar any() para verificar se há valores diferentes de zero ou NaN
            valores_validos = terminais_frequencia(:);
            % Verificar se há valores não-zero E não-NaN
            if any(valores_validos ~= 0 & ~isnan(valores_validos))
                tem_freq_pmu = true;
            end
        end
    end
catch
    % Se houver erro, assumir que não tem
    tem_freq_pmu = false;
end

tem_corrente_dados = exist('tem_corrente', 'var') && ~isempty(tem_corrente) && sum(tem_corrente) > 0;

% Lista de gráficos que requerem corrente
graficos_corrente = {'correnteA.m', 'correnteB.m', 'correnteC.m', 'corrente_trif.m', ...
    'corrente_seq_pos.m', 'corrente_seq_neg.m', 'corrente_seq_zero.m', ...
    'fluxo_ativ.m', 'fluxo_ativoA.m', 'fluxo_ativoB.m', 'fluxo_ativoC.m', ...
    'fluxo_ativ_trif.m', 'fluxo_reat.m', 'fluxo_reativoA.m', 'fluxo_reativoB.m', ...
    'fluxo_reativoC.m', 'fluxo_reat_trif.m', 'fluxo_apar.m', 'fluxo_aparenteA.m', ...
    'fluxo_aparenteB.m', 'fluxo_aparenteC.m', 'fluxo_apar_trif.m'};

% Lista de gráficos que requerem frequência da PMU (terminais_frequencia OU terminais_dados_sp)
graficos_freq_pmu = {'freq_pmu.m'};
% Gráficos que podem usar frequência de terminais_frequencia OU terminais_dados_sp
graficos_freq_calc = {'icg_coerencia.m', 'entropia_coerencia.m', 'matriz_coerencia.m'};

% Lista de gráficos que requerem sequência positiva
graficos_seq_pos = {'tensao_seq_pos.m', 'corrente_seq_pos.m', 'freq_calc.m', ...
    'freq_filt.m', 'freq_FK.m', 'freq_oob.m', 'oscil_fmm.m', 'rocof_calc.m', ...
    'rocov_calc.m', 'taxa_freq_1seg.m', 'dif_angular.m'};

% Lista de gráficos que requerem sequência negativa
graficos_seq_neg = {'tensao_seq_neg.m', 'corrente_seq_neg.m', 'ind_deseq.m'};

% Lista de gráficos que requerem sequência zero
graficos_seq_zero = {'tensao_seq_zero.m', 'corrente_seq_zero.m'};

% Filtrar gráficos disponíveis
graficos_disponiveis = {};
for i = 1:length(lista_graf_completa)
    nome_graf = lista_graf_completa{i};
    
    % Verificar se o gráfico requer corrente
    if any(strcmp(nome_graf, graficos_corrente))
        if ~tem_corrente_dados
            continue; % Pular este gráfico
        end
    end
    
    % Verificar se o gráfico requer frequência da PMU (terminais_frequencia)
    if any(strcmp(nome_graf, graficos_freq_pmu))
        if ~tem_freq_pmu
            continue; % Pular este gráfico
        end
    end
    
    % Verificar se o gráfico pode usar frequência calculada (terminais_dados_sp)
    if any(strcmp(nome_graf, graficos_freq_calc))
        % Pode usar terminais_frequencia OU terminais_dados_sp
        tem_freq_qualquer = tem_freq_pmu || tem_sequencia;
        if ~tem_freq_qualquer
            continue; % Pular este gráfico
        end
    end
    
    % Verificar se o gráfico requer sequência positiva
    if any(strcmp(nome_graf, graficos_seq_pos))
        if ~tem_sequencia
            continue; % Pular este gráfico
        end
    end
    
    % Verificar se o gráfico requer sequência negativa
    if any(strcmp(nome_graf, graficos_seq_neg))
        if ~tem_sequencia_neg
            continue; % Pular este gráfico
        end
    end
    
    % Verificar se o gráfico requer sequência zero
    if any(strcmp(nome_graf, graficos_seq_zero))
        if ~tem_sequencia_zero
            continue; % Pular este gráfico
        end
    end
    
    % Se passou todas as verificações, adicionar à lista
    graficos_disponiveis{end+1} = nome_graf;
end

% Atualizar listbox3 com apenas os gráficos disponíveis
if ~isempty(graficos_disponiveis)
    set(handles.listbox3, 'String', graficos_disponiveis);
    set(handles.listbox3, 'Value', 1);
    set(handles.listbox3, 'Enable', 'off'); % Desabilitar até selecionar PMU
else
    set(handles.listbox3, 'String', {'Nenhum gráfico disponível para estes dados'});
    set(handles.listbox3, 'Value', 1);
    set(handles.listbox3, 'Enable', 'off');
end
end

% Função auxiliar para converter SOC (Unix timestamp) para tempo relativo
function tempo_relativo = converter_tempo_soc_para_relativo(tempo_soc)
    if isempty(tempo_soc)
        tempo_relativo = [];
        return;
    end
    
    % Se o tempo contém valores Unix timestamp (muito grandes), converter para relativo
    if max(tempo_soc) > 1e9  % Valores maiores que 1 bilhão são provavelmente Unix timestamps
        tempo_inicial = tempo_soc(1); % Primeiro SOC (início da gravação)
        tempo_relativo = tempo_soc - tempo_inicial; % Tempo relativo em segundos
    elseif min(tempo_soc) > 0 && max(tempo_soc) > 1000
        % Se ainda parece ser Unix timestamp (valores grandes mas não tão grandes)
        tempo_inicial = tempo_soc(1);
        tempo_relativo = tempo_soc - tempo_inicial;
    else
        % Já está em formato relativo ou outro formato
        tempo_relativo = tempo_soc;
    end
end

% Função auxiliar para ajustar tempo baseado no gráfico que será plotado
% Apenas ajusta o tamanho do vetor tempo para corresponder aos dados
function ajustar_tempo_para_grafico(nome_grafico)
global tempo terminais_dados terminais_dados_sp terminais_dados_sn terminais_dados_s0 ...
    terminais_frequencia terminais_qtde selecao taxa_amos fator_tempo

% Determinar qual fonte de dados será usada baseado no nome do gráfico
if contains(nome_grafico, 'freq_pmu')
    % Usa terminais_frequencia
    if exist('terminais_frequencia', 'var') && ~isempty(terminais_frequencia)
        tamanho_dados = size(terminais_frequencia, 2);
        if exist('terminais_dados', 'var') && ~isempty(terminais_dados) && size(terminais_dados, 2) >= tamanho_dados
            tempo_soc_temp = terminais_dados(1, 1:tamanho_dados, 1);
            % Armazenar SOC original
            tempo_soc_original = tempo_soc_temp;
            % Converter para relativo se for SOC
            if ~isempty(tempo_soc_temp) && all(tempo_soc_temp > 0) && max(tempo_soc_temp) > 1e9
                tempo_inicial = tempo_soc_temp(1);
                tempo = tempo_soc_temp - tempo_inicial;
            else
                tempo = tempo_soc_temp;
                tempo_soc_original = tempo_soc_temp;
            end
        elseif exist('taxa_amos', 'var') && ~isempty(taxa_amos) && taxa_amos > 0
            tempo = (0:(tamanho_dados-1)) / taxa_amos;
            tempo_soc_original = []; % Não há SOC neste caso
        else
            tempo = 0:(tamanho_dados-1);
            tempo_soc_original = []; % Não há SOC neste caso
        end
        fator_tempo = 1;
    end
elseif contains(nome_grafico, 'seq_pos') || contains(nome_grafico, 'seq_neg') || ...
       contains(nome_grafico, 'seq_zero') || contains(nome_grafico, 'freq_calc') || ...
       contains(nome_grafico, 'freq_filt') || contains(nome_grafico, 'freq_FK') || ...
       contains(nome_grafico, 'freq_oob') || contains(nome_grafico, 'oscil') || ...
       contains(nome_grafico, 'rocof') || contains(nome_grafico, 'rocov') || ...
       contains(nome_grafico, 'taxa_freq') || contains(nome_grafico, 'dif_angular') || ...
       contains(nome_grafico, 'ind_deseq')
    % Usa terminais_dados_sp, terminais_dados_sn ou terminais_dados_s0
    if contains(nome_grafico, 'seq_pos') || contains(nome_grafico, 'freq_calc') || ...
       contains(nome_grafico, 'freq_filt') || contains(nome_grafico, 'freq_FK') || ...
       contains(nome_grafico, 'freq_oob') || contains(nome_grafico, 'oscil') || ...
       contains(nome_grafico, 'rocof') || contains(nome_grafico, 'rocov') || ...
       contains(nome_grafico, 'taxa_freq') || contains(nome_grafico, 'dif_angular')
        dados_fonte = 'terminais_dados_sp';
    elseif contains(nome_grafico, 'seq_neg') || contains(nome_grafico, 'ind_deseq')
        dados_fonte = 'terminais_dados_sn';
    else
        dados_fonte = 'terminais_dados_s0';
    end
    
    if exist(dados_fonte, 'var')
        dados = eval(dados_fonte);
        if ~isempty(dados)
            tamanho_dados = size(dados, 2);
            if exist('terminais_dados', 'var') && ~isempty(terminais_dados) && size(terminais_dados, 2) >= tamanho_dados
                tempo_soc_temp = terminais_dados(1, 1:tamanho_dados, 1);
                % Armazenar SOC original para tooltip
                tempo_soc_original = tempo_soc_temp;
                % Converter para relativo se for SOC
                if ~isempty(tempo_soc_temp) && all(tempo_soc_temp > 0) && max(tempo_soc_temp) > 1e9
                    tempo_inicial = tempo_soc_temp(1);
                    tempo = tempo_soc_temp - tempo_inicial;
                else
                    tempo = tempo_soc_temp;
                    tempo_soc_original = tempo_soc_temp;
                end
            elseif exist('taxa_amos', 'var') && ~isempty(taxa_amos) && taxa_amos > 0
                tempo = (0:(tamanho_dados-1)) / taxa_amos;
                tempo_soc_original = []; % Não há SOC neste caso
            else
                tempo = 0:(tamanho_dados-1);
                tempo_soc_original = []; % Não há SOC neste caso
            end
            fator_tempo = 1;
        end
    end
else
    % Usa terminais_dados (gráficos básicos de tensão/corrente)
    if exist('terminais_dados', 'var') && ~isempty(terminais_dados)
        tamanho_dados = size(terminais_dados, 2);
        tempo_soc_temp = terminais_dados(1, 1:tamanho_dados, 1);
        % Armazenar SOC original
        tempo_soc_original = tempo_soc_temp;
        % Converter para relativo se for SOC
        if ~isempty(tempo_soc_temp) && all(tempo_soc_temp > 0) && max(tempo_soc_temp) > 1e9
            tempo_inicial = tempo_soc_temp(1);
            tempo = tempo_soc_temp - tempo_inicial;
        else
            tempo = tempo_soc_temp;
            tempo_soc_original = tempo_soc_temp;
        end
        fator_tempo = 1;
    end
end
end

