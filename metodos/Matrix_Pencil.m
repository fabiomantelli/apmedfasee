function varargout = Matrix_Pencil(varargin)
% Matrix_Pencil MATLAB code for Matrix_Pencil.fig
%      Matrix_Pencil, by itself, creates a new Matrix_Pencil or raises the existing
%      singleton*.
%
%      H = Matrix_Pencil returns the handle to a new Matrix_Pencil or the handle to
%      the existing singleton*.
%
%      Matrix_Pencil('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in Matrix_Pencil.M with the given input arguments.
%
%      Matrix_Pencil('Property','Value',...) creates a new Matrix_Pencil or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before Matrix_Pencil_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to Matrix_Pencil_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help Matrix_Pencil

% Last Modified by GUIDE v2.5 27-Aug-2014 17:58:10

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @Matrix_Pencil_OpeningFcn, ...
    'gui_OutputFcn',  @Matrix_Pencil_OutputFcn, ...
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


% --- Executes just before Matrix_Pencil is made visible.
function Matrix_Pencil_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to Matrix_Pencil (see VARARGIN)

% Choose default command line output for Matrix_Pencil
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global graf_sel aux_graf tempo
% Escreve o nome do sinal selecionado
set(handles.text2,'String',graf_sel(aux_graf,:));
% Escreve os intervalos da consulta
set(handles.edit1,'String',(tempo(1)));
set(handles.edit2,'String',(tempo(length(tempo))));
set(handles.edit3,'String',(1));
set(handles.edit4,'String',(length(tempo)));
set(handles.edit5,'String',round(length(tempo)/4));

% UIWAIT makes Matrix_Pencil wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = Matrix_Pencil_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;


% Ajuste automático do tempo inicial (segundos)
function edit1_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit1,'String'));
if aux > str2num(get(handles.edit2,'String')) || aux < 0; aux=0; set(handles.edit1,'String',num2str(aux)); end
aux1 = find(tempo==aux); % Posição com o tempo selecionado
set(handles.edit3,'String',num2str(aux1));
% Recalcula ordem do modelo
set(handles.edit5,'String',round((str2num(get(handles.edit4,'String'))-str2num(get(handles.edit3,'String')))*5/12));


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Ajuste automático do tempo final (segundos)
function edit2_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit2,'String'));
if aux > tempo(length(tempo)) || aux < str2num(get(handles.edit1,'String')); aux=tempo(length(tempo)); set(handles.edit2,'String',num2str(aux));end
aux1 = find(tempo==aux); % Posição com o tempo selecionado
set(handles.edit4,'String',num2str(aux1));
% Recalcula ordem do modelo
set(handles.edit5,'String',round((str2num(get(handles.edit4,'String'))-str2num(get(handles.edit3,'String')))*5/12));

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% Ajuste automático do tempo inicial (amostras)
function edit3_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit3,'String'));
if aux > str2num(get(handles.edit4,'String')) || aux < 1; aux=1; set(handles.edit3,'String',num2str(aux));end
set(handles.edit1,'String',num2str(tempo(aux)));
% Recalcula ordem do modelo
set(handles.edit5,'String',round((str2num(get(handles.edit4,'String'))-str2num(get(handles.edit3,'String')))*5/12));

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

function edit4_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit4,'String'));
if aux > length(tempo)|| aux < str2num(get(handles.edit3,'String')); aux=length(tempo); set(handles.edit4,'String',num2str(aux));end
set(handles.edit2,'String',num2str(tempo(aux)));
% Recalcula ordem do modelo
set(handles.edit5,'String',round((str2num(get(handles.edit4,'String'))-str2num(get(handles.edit3,'String')))*5/12));


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global terminais_qtde selecao terminais_cor taxa_amos sinal  legenda terminal_nome tempo fator_tempo %unidade sinal_nome
t1 = str2num(get(handles.edit3,'String'));
t2 = str2num(get(handles.edit4,'String'));

% Método Matrix_Pencil Multissinais
% Valmor Zimmer 29/07/2014
% Baseado no código do Thiago.

N = length(sinal(1,t1:t2));
L = fix(str2num(get(handles.edit5,'String')));  % Parâmetro Pencil

% Prepara  o sinal caso o tira tendência tenha sido selecionado
% sinalP --> sinal pronto para análise.
for i=1:1:terminais_qtde
    if selecao(i)==1 % verifica se foi escolhida para plotar
        % FILTRO
        if get(handles.checkbox2,'value') == 1; % filtra o sinal
            ordem_F=str2num(get(handles.edit7,'String'));
            sinalP(i,1:ordem_F)=sinal(i,ordem_F);
            for ii=ordem_F+1:length(sinal(i,:))
                sinalP(i,ii) = sinalP(i,ii-1)+(sinal(i,ii)-sinal(i,ii-ordem_F))/ordem_F;
            end
        else sinalP=sinal;    
        end
        % DTREND
        if get(handles.checkbox1,'value') == 1; % Tira a tendência
            sinalP(i,1:(t2-t1)+1) = dtrend(sinal(i,t1:t2));
        else
            sinalP(i,1:(t2-t1)+1) = sinal(i,t1:t2);
        end
    end
end

%--------------------------------------------------------------------------
% Construção do MPL com ordem reduzida
Yp = []; 
for i=1:1:terminais_qtde
    if selecao(i)==1 % verifica se foi escolhida para plotar
        for ii=1:(N-L)
            for iii=1:L+1
                Yp(ii,iii) = sinalP(i,iii+ii-1);
            end
        end
%         H = [H;Haux]; % Concatena as matrizes do MPL
%         x = [x;xaux.'];
    end
end
%------------------------------------------------------
% Calcula os valores singulares
[U,S,V] = svd(Yp); % o zero elimina a ultima linha nula, tornando a quadrada.
Vmax    = max(max(S)); % Máximo valor singular;

tol=10^-3;
i=1;
Vi=[];
for ii=1:min(size(S))
	if S(ii,ii)/Vmax>tol;
		Vi(:,i)=V(:,ii);
		i=i+1;
	end
end
V1 = Vi(1:L  ,:);
V2 = Vi(2:L+1,:);
a = pinv(conj(V1'))*conj(V2');
%--------------------------------------------------------------------------
% Determinação dos parâmetros
raizes = eig(a);                             % raízes PLANO Z
raizes_s = log(raizes)*taxa_amos;                   % raízes PLANO S
freq = angle(raizes)./(2*pi*(1/taxa_amos));              % frequencia do modo
fat_amor = real((raizes_s));             % fator de amortecimento
taxa_amor = (-real(raizes_s)./abs(raizes_s))*100;    % taxa de amortecimento
%--------------------------------------------------------------------------
% Cálculo de amplitude e fase dos modos de oscilação
ampl = [];fase = []; j=1;  Hi=[];
for i=1:terminais_qtde
    z=[];xx=[];
    if selecao(i)==1
        for ii = 1:1:L
            for iii = 1:1:L
                z(ii,iii)=raizes(iii)^ii;
            end
            xx(ii) = sinalP(i,ii);
        end
        Hi(j,:)   = (z^-1)*xx.';
        ampl(j,:) = abs(Hi(j,:));   % Amplitude
        fase(j,:) = angle(Hi(j,:)); % Fase
        j=j+1;
    end
end

% Energia
n=0:1:N; energy = [];
for i=1:sum(selecao)
    for ii=1:L
        energy(i,ii)=abs(ampl(i,ii)^2)*(sum(abs(raizes(ii).^n).^2));
    end
end
%-------------------------------------------------------------------------
% Filtro que seleciona os modos dominantes omitindo a componente contínua
F = str2num(get(handles.edit6,'String'));;
m = 0;
freq1 = [];raizes_s1 = [];taxa_amor1 = [];ampl1 = [];fase1 = [];fat_amor1 = [];energy1 = [];
for i=1:L
    if  freq(i)<F && freq(i)>0.009  && taxa_amor(i)<40
        m = m+1;
        freq1(m)      = freq(i);       % Frequência
        raizes_s1(m)  = raizes_s(i);   % Raízes do modelo
        taxa_amor1(m) = taxa_amor(i);  % Taxa de amortecimento
        ampl1(:,m)    = ampl(:,i);     % Amplitudes das oscilações
        fase1(:,m)    = fase(:,i);     % Fases
        fat_amor1(m)  = fat_amor(i);   % Fator de amortecimento
        energy1(:,m)  = energy(:,i);   % Energia de cada modo
        Hi1(:,m)      = Hi(:,i);
    end
end

%--------------------------------------------------------------------------
%Imprime os dados na tela
disp ('===================================================================================================')
disp ('                            Método Matrix Pencil (Mono e Multissinais)                             ')
disp ('===================================================================================================')
disp ('                                       DADOS DE SAIDA                                              ')
fprintf('Ordem do Modelo ...........: %g  \n',L)
fprintf('Janela de dados............: %g seg\n',N/taxa_amos)
fprintf('Frequência de corte........: %g Hz \n',F)

fprintf('\n|======|=================|===========|==========');
for i=1:1:terminais_qtde
    if selecao(i)==1
        fprintf('|')
        igual=fix((29-max(find(terminal_nome(i,:))))/2); %vai colocar os igual de acordo com o tamanho do nome
        for ii=1:igual; fprintf('='); end
        fprintf('%c',terminal_nome(i,:)) %coloca o nome
        igual = 29 - igual - max(find(terminal_nome(i,:))); %verifica quandos igual faltou
        for ii=1:igual; fprintf('='); end
    end
end

%2ª Linha do cabeçalho
fprintf('\n| MODO |     RAIZES      | FREQ (hz) | DAMP (%%)'); % o '%% é para aparecer %, senão programa quebra achando que vem algum numero do %i etc..

for i=1:1:sum(selecao)
    fprintf(' | ENERGIA%2d   AMP%2d   FASE%2d ',i,i,i);
end
fprintf('\n|======|=================|===========|==========');
for i=1:1:sum(selecao)
    fprintf('|=============================');
end
fprintf('\n');
for i =1:m
    fprintf('%4d ',real(i));
    fprintf('%10.3f ',real(raizes_s1(i)))
    fprintf('%7.3fi ',imag(raizes_s1(i)))
    fprintf('%10.3f ',(freq1(i)))
    fprintf('%10.2f ',(taxa_amor1(i)))
    for ii=1:1:sum(selecao)
        fprintf('%10.3f ',(energy1(ii,i)))
        fprintf('%8.3f ',(ampl1(ii,i)))
        fprintf('%9.2f ',rad2deg(fase1(ii,i)))
    end
    fprintf('\n')
end
fprintf('|======|=================|===========|==========');
for i=1:1:sum(selecao)
    fprintf('|=============================');
end
fprintf('\n')

%--------------------------------------------------------------------------
% Reconstrução dos sinais com todos os modos
ok = input('Deseja traçar os sinais estimados? (SIM=1) (NÃO=0)');
if ok == 1
    t = [0:1/taxa_amos:((N-1)/taxa_amos)];
    y_est=[]; legendap=[];
    figure;   hold on
    q = 0;
    for i=1:terminais_qtde
        if selecao(i)==1
            q = q + 1;
            for j = 1:1:N
                a = 0;
                for ii = 1:L
                    a = a+ampl(q,ii)*exp(fat_amor(ii)*t(j))*cos(2*pi*freq(ii)*t(j)+fase(q,ii));
                end
                y_est(q,j) = a;
            end
            P1 = plot(tempo(t1:t2)/fator_tempo,sinalP(i,:));
            set(P1,'color',str2num(terminais_cor(i,:)));
            P2 = plot(tempo(t1:t2)/fator_tempo,y_est(q,:));
            set(P2,'color',str2num(terminais_cor(i,:)),'LineStyle','--');
            legendap{(2*q)-1} = terminal_nome(i,:);
            legendap{(2*q)}   = strcat(terminal_nome(i,:),' Estimado');
        end
    end
    title ('Método de Prony Multi-sinais - Sinal Original e Estimado')
    legend(legendap)
    grid on
    xlim([min(tempo(t1)/fator_tempo) max(tempo(t2)/fator_tempo)])
end

%--------------------------------------------------------------------------
% Reconstrução dos sinais com todos os principais modos
ok = input('Deseja traçar os sinais com os principais modos estimados? (SIM=1) (NÃO=0)');
if ok == 1
    t = [0:1/taxa_amos:((N-1)/taxa_amos)];
    y_est=[];   legendap=[];
    figure;     hold on
    q = 0;
    for i=1:terminais_qtde
        if selecao(i)==1
            q = q + 1;
            for j = 1:1:N
                a = 0;
                for ii = 1:m
                    a = a+2*ampl1(q,ii)*exp(fat_amor1(ii)*t(j))*cos(2*pi*freq1(ii)*t(j)+fase1(q,ii));
                end
                y_est(q,j) = a;
            end
            P1 = plot(tempo(t1:t2)/fator_tempo,sinalP(i,:));
            set(P1,'color',str2num(terminais_cor(i,:)));
            P2 = plot(tempo(t1:t2)/fator_tempo,y_est(q,:));
            set(P2,'color',str2num(terminais_cor(i,:)),'LineStyle','--');
            legendap{(2*q)-1} = terminal_nome(i,:);
            legendap{(2*q)}   = strcat(terminal_nome(i,:),' Estimado');
        end
    end
    title ('Método de Prony Multi-sinais - Principais Modos de Oscilação')
    legend(legendap)
    grid on
    xlim([min(tempo(t1)/fator_tempo) max(tempo(t2)/fator_tempo)])
end

%--------------------------------------------------------------------------
disp ('===================================================================================================')
disp ('                                    Mode-shapes (Formas Modais)                                    ')
disp ('===================================================================================================')
ok = input('Deseja traçar os Mode Shapes? (SIM=1) (NÃO=0)');
[X,Y] = pol2cart(fase1,ampl1);
while ok == 1
    mode = input('Defina o número do modo que desejas traçar:');
    cor = find(selecao); % variável auxiliar para manter as cores dos terminais selecionados
    if mode <= m
        %------------------------------------------------------------------
        % Rotina para setar o gráfico polar na maior amplitude do modo
        % Traça a maior amplitude primeiro para ajustar a escala do gráfico
        Amax = max(abs(ampl1(:,mode))); % Maior amplitude
        [X1,Y1] = pol2cart(0,Amax);     % Passa para o plano cartesiano
        figure
        H = compass(X1,Y1);             % Traça
        set(H,'Color',[1,1,1]);         % Apaga a seta
        hold on
        %------------------------------------------------------------------
        for i=1:sum(selecao)
            H = compass(X(i,mode),Y(i,mode));
            set(H,'Color',str2num(terminais_cor(cor(i),:)),'linewidth',2);
        end
        legend(['PMUs' legenda]); % Esse PMUs foi inserido devido ao set do tamanho do compass
        title(['Mode Shapes associados ao modo de ',num2str(freq1(mode)),' Hz'])
        ok = input('Deseja traçar mais um Mode Shapes? (SIM=1) (NÃO=0)');
    else
        fprintf(['Defina um modo entre 1 e ',num2str(m),'.\n'])
    end
end

%--------------------------------------------------------------------------
disp ('===================================================================================================')
disp ('                                   Fatores de Participação                                         ')
disp ('===================================================================================================')
% Código baseado nos resultados da dissertação do Moisés.
if sum(selecao)>1 % Fatores de participação só podem ser traçados com multissinais
    ok = input('Deseja traçar os Fatores de Participação? (SIM=1) (NÃO=0)');
    if ok == 1
        selecaoF = selecao;               % Vetor de seleção auxiliar 1 
        sel_aux  = find(selecao);
        % Definição de sinais a serem utilizados
        % Obs.: se o numero de sinais for impar é necessário eliminar um sinal
        j=0;
        while (mod(sum(selecaoF),2)==1) || (sum(selecaoF)>(length(freq1(1,:))*2))
            j=j+1;
            for i=1:terminais_qtde
                if selecaoF(i)==1
                    fprintf('%d  %s\n',i, terminal_nome(i,:))
                end
            end
            sel = input('Você deve eliminar um dos terminais, escolha o índice do terminal: ');
            selecaoF(sel)=0;            % Apaga o terminal do vetor de seleção auxiliar 1
            Hi1(sel_aux==sel,:)=[];     % Apaga os coeficientes do terminal eliminado
            sel_aux = find(selecaoF);   % Redimenciona o vetor de sel_aux
        end
        
        % Escolha dos modos de oscilação
        fprintf('Você pode escolher no máximo %d modos de oscilação',fix(sum(selecao)/2))
        for i=1:sum(selecaoF)/2
            fprintf('\n Escolha o modo %d: ',i);
            mode(i) = input('');
        end
        
        % Montagem do autovetor a direita dos modos selecionados
        for i=1:sum(selecaoF)
            for ii=1:length(mode(:))
                v(i,(2*ii-1)) = Hi1(i,mode(ii)); % insere o complexo conjugado na estimação
                v(i,(2*ii))   = conj(Hi1(i,mode(ii)));
            end
        end
        
        % Montagem do vetor de autovaloresdos dos modos selecionados
        for i=1:length(mode(:))
            D(2*i-1) = raizes_s1(mode(i));
            D(2*i)   = conj(raizes_s1(mode(i)));
        end
        
        Aest    = v*diag(D)*v^-1;     % Modelo do sistema
        [AD,D1] = eig(Aest);        % Autovetor a direita  (cada coluna é um autovetor da matriz Modelo)
        [AE,D2] = eig(Aest.');      % Autovetor a esquerda (cada coluna é um autovetor da matriz Modelo)
        AE      = conj(AE);   
        
         % Os AD e AE não saem ordenados corretamente. Assim, é necessário reordenar
        AEr=[];
        for i=1:length(D1)
            for ii=1:length(D1)
                if (abs(real(D1(i,i))-real(D2(ii,ii))) < 0.0001) && (abs(imag(D1(i,i))-imag(D2(ii,ii))) < 0.0001)
                   AEr(:,i) = AE(:,ii); 
                end
            end
        end
        % Fatores de Participação 
        for i=1:length(D1) % modos
            S(i) = abs(AEr(i,:))*abs(AD(i,:)');
            for ii=1:length(D1) % terminais
                P(i,ii)=(abs(AEr(i,ii))*abs(AD(i,ii)))/S(i);
            end
        end
        %------------------------------------------------------------------------------
        % Traça o Histograma dos Fatores de Participação
        leg_mod = num2str(diag(imag(D1)/(2*pi))); % Frequência dos modos
        for i = 1:length(D1)
            j=0;
            for ii=1:terminais_qtde
                if selecaoF(ii)==1
                    j = j + 1;
                    legendaF{j}= terminal_nome(ii,:);
                end
            end
        end
        % Eixo são os modos
        figure
        h = bar (P');
        legend(legendaF)
        title(['Fatores de Participação'])
        xlabel('Modos de Oscilação')
        grid on
        set(gca,'XTick',1:1:length(D1))
        set(gca,'XTickLabel',{leg_mod})
        
        % Eixo são as barras
        figure
        h= bar (P);
        legend({leg_mod})
        title(['Fatores de Participação'])
        xlabel('Barras')
        grid on
        set(gca,'XTick',1:1:length(D1))
        set(gca,'XTickLabel',legendaF)
        
%         sum(P')
    end
end


% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
cd ..
set(medfasee,'Visible','on');
delete(hObject);


% --- Executes on button press in checkbox1.
function checkbox1_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox1



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
global terminais_qtde selecao terminais_cor sinal  unidade sinal_nome tempo fator_tempo terminal_nome tempo_legenda
t1 = str2num(get(handles.edit3,'String'));
t2 = str2num(get(handles.edit4,'String'));
figure; hold; v=0;
for i=1:1:terminais_qtde
    if selecao(i)==1 % verifica se foi escolhida para plotar
        % FILTRO
        if get(handles.checkbox2,'value') == 1; % filtra o sinal
            ordem_F = str2num(get(handles.edit7,'String'));
            sinalP(i,1:ordem_F)=sinal(i,ordem_F);
            for ii=ordem_F+1:length(sinal(i,:))
                sinalP(i,ii) = sinalP(i,ii-1)+(sinal(i,ii)-sinal(i,ii-ordem_F))/ordem_F;
            end
        else sinalP=sinal;    
        end
        
        % DTREND
        if get(handles.checkbox1,'value') == 1; % Tira a tendência
            H = plot(tempo(t1:t2)/fator_tempo,dtrend(sinalP(i,t1:t2)));
        else
            H = plot(tempo(t1:t2)/fator_tempo,sinalP(i,t1:t2));
        end;
        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);
        v=v+1;
        legendan{v} = terminal_nome(i,:);
    end
end
grid on;
title(sinal_nome);
ylabel(unidade);
xlim([min(tempo(t1)/fator_tempo) max(tempo(t2)/fator_tempo)])
xlabel(tempo_legenda);
legend(legendan);

function edit6_Callback(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit6 as text
%        str2double(get(hObject,'String')) returns contents of edit6 as a double

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox2.
function checkbox2_Callback(hObject, eventdata, handles)
if get(handles.checkbox2,'value') == 1;
    set(handles.edit7,'Enable','on')
    set(handles.text13,'Enable','on')
else
    set(handles.edit7,'Enable','off')
    set(handles.text13,'Enable','off')
end



function edit7_Callback(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit7 as text
%        str2double(get(hObject,'String')) returns contents of edit7 as a double


% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit7 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
