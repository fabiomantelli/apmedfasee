function varargout = DFT(varargin)
% DFT MATLAB code for DFT.fig
%      DFT, by itself, creates a new DFT or raises the existing
%      singleton*.
%
%      H = DFT returns the handle to a new DFT or the handle to
%      the existing singleton*.
%
%      DFT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFT.M with the given input arguments.
%
%      DFT('Property','Value',...) creates a new DFT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFT_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFT_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFT

% Last Modified by GUIDE v2.5 06-Jun-2014 09:41:50

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DFT_OpeningFcn, ...
    'gui_OutputFcn',  @DFT_OutputFcn, ...
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


% --- Executes just before DFT is made visible.
function DFT_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFT (see VARARGIN)

% Choose default command line output for DFT
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

% UIWAIT makes DFT wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = DFT_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% Ajuste automático do tempo inicial (segundos)
function edit1_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit1,'String'));
if aux > str2num(get(handles.edit2,'String')) || aux < 0; aux=0; set(handles.edit1,'String',num2str(aux)); end
aux1 = find(tempo==aux); % Posição com o tempo selecionado
set(handles.edit3,'String',num2str(aux1));

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

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global terminais_qtde selecao terminais_cor taxa_amos sinal  legenda unidade sinal_nome terminal_nome
t1 = str2num(get(handles.edit3,'String'));
t2 = str2num(get(handles.edit4,'String'));

% Fast Fourier Transform
% Valmor Zimmer 28/06/2010
% Baseado no livro Understanding Digital Processing By Richard G.Lyons 2004
if length(size(sinal))==2 % sinais monofásicos
    figure; hold on
    N = length(sinal(1,t1:t2)-1);% Número de Amostras
    if mod(N,4)~=0; N=N-1; if mod(N,4)~=0; N=N-1;if mod(N,4)~=0; N=N-1; end;end;end  % faz isso para ser múltiplo de 4
    vj = [0:1:((N/4)-1)]; % Vetor auxiliar (n)
    vjj = [0:1:((N/2)-1)]; % Vetor auxiliar (m)
    aux1 = (cos((2*pi*vj'*vjj)/(N/4)) - 1i * sin((2*pi*vj'*vjj)/(N/4)));
    aux2 = (cos((2*pi*vjj)/(N/2)) - 1i* sin((2*pi*vjj)/(N/2)));
    aux3 = (cos((2*pi*vjj)/(N)) - 1i * sin((2*pi*vjj)/(N)));
    f = vjj * taxa_amos / N; % Frequências do Espectro
    
    for i=1:1:terminais_qtde
        if selecao(i)==1 % verifica se foi escolhida para plotar
            %---------------------------------------------------------------------
            % Cálculo das Componentes em função da Matriz Base (senos e cossenos)
            A1 = aux1'*sinal(i,t1:4:t2-1)';
            A2 = aux1'*sinal(i,t1+2:4:t2)';
            B1 = aux1'*sinal(i,t1+1:4:t2)';
            B2 = aux1'*sinal(i,t1+3:4:t2)';
            A = A1 + aux2'.*A2;
            B = B1 + aux2'.*B2;
            X = A + aux3'.*B;
            Xamp = abs(X); % Cálculo da Amplitude
            Amp(i,:) = Xamp*2/N; % "Normaliza a amplitude"
            H = plot(f(2:N/2-1),Amp(i,2:N/2-1)); % Espectro
            set(H,'Color',str2num(terminais_cor(i,:)), 'LineWidth', 2)
        end
    end
    title(strcat('Espectro de Frequência - ',sinal_nome))
    ylabel(strcat('Amplitude  [',unidade,']'));
    xlabel('Frequência (Hz)');
    grid on;
    axis([f(2) 1.6 5e-5 0.3])
    set(gca,'YScale','linear');
    set(gca,'YLimMode','auto');
    legend(legenda);
    clear sinal
    close(DFT)
    
else %sinais trifásicos
    N = length(sinal(1,t1:t2,1)-1);% Número de Amostras
    if mod(N,4)~=0; N=N-1; if mod(N,4)~=0; N=N-1;if mod(N,4)~=0; N=N-1; end;end;end  % faz isso para ser múltiplo de 4
    vj = [0:1:((N/4)-1)]; % Vetor auxiliar (n)
    vjj = [0:1:((N/2)-1)]; % Vetor auxiliar (m)
    aux1 = (cos((2*pi*vj'*vjj)/(N/4)) - 1i * sin((2*pi*vj'*vjj)/(N/4)));
    aux2 = (cos((2*pi*vjj)/(N/2)) - 1i* sin((2*pi*vjj)/(N/2)));
    aux3 = (cos((2*pi*vjj)/(N)) - 1i * sin((2*pi*vjj)/(N)));
    f = vjj * taxa_amos / N; % Frequências do Espectro
    for i=1:1:terminais_qtde
        if selecao(i)==1 % verifica se foi escolhida para plotar
            figure; hold on
            for ii=1:3
                %---------------------------------------------------------------------
                % Cálculo das Componentes em função da Matriz Base (senos e cossenos)
                A1 = aux1'*sinal(i,t1:4:t2-1,ii)';
                A2 = aux1'*sinal(i,t1+2:4:t2,ii)';
                B1 = aux1'*sinal(i,t1+1:4:t2,ii)';
                B2 = aux1'*sinal(i,t1+3:4:t2,ii)';
                A = A1 + aux2'.*A2;
                B = B1 + aux2'.*B2;
                X = A + aux3'.*B;
                Xamp = abs(X); % Cálculo da Amplitude
                Amp(i,:) = Xamp*2/N; % "Normaliza a amplitude"
                H = plot(f(2:N/2-1),Amp(i,2:N/2-1)); % Espectro
                
                if ii==1; set(H,'Color','r','LineWidth', 2); end
                if ii==2; set(H,'Color','b','LineWidth', 2); end
                if ii==3; set(H,'Color','g','LineWidth', 2); end
            end
            title(strcat('Espectro de Frequência - ',sinal_nome,terminal_nome(i,:)))
            ylabel(strcat('Amplitude  [',unidade,']'));
            xlabel('Frequência (Hz)');
            grid on;
            axis([f(2) 1.6 5e-5 0.3])
            set(gca,'YScale','linear');
            set(gca,'YLimMode','auto');
            legend('Fase A','Fase B','Fase C');
        end
    end
    clear sinal
    close(DFT)
end

% --- Executes when user attempts to close figure1.
function figure1_CloseRequestFcn(hObject, eventdata, handles)
cd ..
set(medfasee,'Visible','on');
delete(hObject);
