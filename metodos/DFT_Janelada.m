function varargout = DFT_Janelada(varargin)
% DFT_Janelada MATLAB code for DFT_Janelada.fig
%      DFT_Janelada, by itself, creates a new DFT_Janelada or raises the existing
%      singleton*.
%
%      H = DFT_Janelada returns the handle to a new DFT_Janelada or the handle to
%      the existing singleton*.
%
%      DFT_Janelada('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in DFT_Janelada.M with the given input arguments.
%
%      DFT_Janelada('Property','Value',...) creates a new DFT_Janelada or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before DFT_Janelada_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to DFT_Janelada_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help DFT_Janelada

% Last Modified by GUIDE v2.5 13-Jan-2015 11:35:27

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
    'gui_Singleton',  gui_Singleton, ...
    'gui_OpeningFcn', @DFT_Janelada_OpeningFcn, ...
    'gui_OutputFcn',  @DFT_Janelada_OutputFcn, ...
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


% --- Executes just before DFT_Janelada is made visible.
function DFT_Janelada_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to DFT_Janelada (see VARARGIN)

% Choose default command line output for DFT_Janelada
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
global graf_sel aux_graf tempo taxa_amos
% Escreve o nome do sinal selecionado
set(handles.text2,'String',graf_sel(aux_graf,:));
% Escreve os intervalos da consulta
set(handles.edit1,'String',(tempo(1)));
set(handles.edit2,'String',(tempo(length(tempo))));
set(handles.edit3,'String',(1));
set(handles.edit4,'String',(length(tempo)));
set(handles.edit5,'String',30);
set(handles.edit6,'String',30*taxa_amos);
set(handles.edit7,'String',5);
set(handles.edit8,'String',5*taxa_amos);
set(handles.edit9,'String',2/(30));
set(handles.edit10,'String',3);

% UIWAIT makes DFT_Janelada wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% --- Outputs from this function are returned to the command line.
function varargout = DFT_Janelada_OutputFcn(hObject, eventdata, handles)
varargout{1} = handles.output;

% Ajuste automático do tempo inicial (segundos)
function edit1_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit1,'String'));
if aux >= str2num(get(handles.edit2,'String')) || aux < 0; aux=0; set(handles.edit1,'String',num2str(aux)); end
aux1 = find(tempo==aux); % Posição com o tempo selecionado
set(handles.edit3,'String',num2str(aux1));

% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
% Ajuste automático do tempo final (segundos)
function edit2_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit2,'String'));
if aux > tempo(length(tempo)) || aux <= str2num(get(handles.edit1,'String')); aux=tempo(length(tempo)); set(handles.edit2,'String',num2str(aux));end
aux1 = find(tempo==aux); % Posição com o tempo selecionado
set(handles.edit4,'String',num2str(aux1));

% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
% Ajuste automático do tempo inicial (amostras)
function edit3_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit3,'String'));
if aux >= str2num(get(handles.edit4,'String')) || aux < 1; aux=1; set(handles.edit3,'String',num2str(aux));end
set(handles.edit1,'String',num2str(tempo(aux)));

% --- Executes during object creation, after setting all properties.
function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
% Ajuste automático do tempo final (amostras)
function edit4_Callback(hObject, eventdata, handles)
global tempo
aux = str2num(get(handles.edit4,'String'));
if aux > length(tempo)|| aux <= str2num(get(handles.edit3,'String')); aux=length(tempo); set(handles.edit4,'String',num2str(aux));end
set(handles.edit2,'String',num2str(tempo(aux)));

% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
% Ajuste automático do tamanho da janela (segundos)
function edit5_Callback(hObject, eventdata, handles)
global taxa_amos
aux = str2num(get(handles.edit5,'String'));
aux1 = aux*taxa_amos;
if mod(aux1,4)~=0; aux1=aux1-1; if mod(aux1,4)~=0; aux1=aux1-1;if mod(aux1,4)~=0; aux1=aux1-1; end;end;end  % faz isso para ser múltiplo de 4
set(handles.edit5,'String',num2str(aux1/taxa_amos))
if aux1 < str2num(get(handles.edit8,'String')) || aux < 1; aux=30; set(handles.edit5,'String',num2str(aux));end
set(handles.edit6,'String',num2str(aux*taxa_amos));
% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%  Ajuste automático do tamanho da janela (amostras)
function edit6_Callback(hObject, eventdata, handles)
global taxa_amos
aux = str2num(get(handles.edit6,'String'));
if aux < str2num(get(handles.edit8,'String')) || aux < 1; aux=30; set(handles.edit5,'String',num2str(aux));end
set(handles.edit6,'String',num2str(aux*taxa_amos))

% --- Executes during object creation, after setting all properties.
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
%  Ajuste automático do tamanho do passo (segundos)
function edit7_Callback(hObject, eventdata, handles)
global taxa_amos
aux = str2num(get(handles.edit7,'String'));
if aux > str2num(get(handles.edit5,'String')) || aux < 1; aux=5; set(handles.edit7,'String',num2str(aux));end
set(handles.edit8,'String',num2str(aux*taxa_amos));

% --- Executes during object creation, after setting all properties.
function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
%  Ajuste automático do tamanho do passo (amostras)
function edit8_Callback(hObject, eventdata, handles)
global taxa_amos
aux = str2num(get(handles.edit8,'String'));
if aux > str2num(get(handles.edit6,'String')) || aux < 1; aux=5; set(handles.edit7,'String',num2str(aux));end
set(handles.edit8,'String',num2str(aux*taxa_amos));

% --- Executes during object creation, after setting all properties.
function edit8_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end;
%--------------------------------------------------------------------------
%  Ajuste da Frequência Mínima do Gráfico
function edit9_Callback(hObject, eventdata, handles)
global taxa_amos
aux=round((str2num(get(handles.edit9,'String'))*str2num(get(handles.edit6,'String')))/taxa_amos);
set(handles.edit9,'String',num2str(aux*(taxa_amos/str2num(get(handles.edit6,'String')))));
if (str2num(get(handles.edit9,'String'))> str2num(get(handles.edit10,'String'))) || (str2num(get(handles.edit9,'String')) < 0)
    set(handles.edit9,'String',num2str(2*(taxa_amos/str2num(get(handles.edit6,'String')))));
end

% --- Executes during object creation, after setting all properties.
function edit9_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
%--------------------------------------------------------------------------
%  Ajuste da Frequência Maxima do Gráfico
function edit10_Callback(hObject, eventdata, handles)
global taxa_amos
aux=round((str2num(get(handles.edit10,'String'))*str2num(get(handles.edit6,'String')))/taxa_amos);
set(handles.edit10,'String',num2str(aux*(taxa_amos/str2num(get(handles.edit6,'String')))));
if (str2num(get(handles.edit10,'String'))< str2num(get(handles.edit9,'String'))) || (str2num(get(handles.edit10,'String')) > 30)
    set(handles.edit10,'String',num2str(3));
end

% --- Executes during object creation, after setting all properties.
function edit10_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end

%--------------------------------------------------------------------------
%  Executa quando fecha a janela
function figure1_CloseRequestFcn(hObject, eventdata, handles)
cd ..
set(medfasee,'Visible','on');
delete(hObject)


% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
global  taxa_amos sinal  unidade sinal_nome tempo_legenda terminais_qtde selecao terminal_nome
t1 = str2num(get(handles.edit3,'String'));
t2 = str2num(get(handles.edit4,'String'));
N     = str2num(get(handles.edit6,'String'));% Número de Amostras
passo = str2num(get(handles.edit8,'String'));% Passo entre janelas
Fmin  = round((str2num(get(handles.edit9,'String'))*N)/taxa_amos);
Fmax  = round((str2num(get(handles.edit10,'String'))*N)/taxa_amos);
if t2-t1 < N+passo
    warndlg('O período de análise deve ter mais amostras do que a soma de uma janela e um passo!','!! Warning !!');
else
    % Fast Fourier Transform
    % Valmor Zimmer 28/06/2010
    % Baseado no livro Understanding Digital Processing By Richard G.Lyons 2004
    if length(size(sinal))==2 % sinais monofásicos
        vj = [0:1:((N/4)-1)]; % Vetor auxiliar (n)
        vjj = [0:1:((N/2)-1)]; % Vetor auxiliar (m)
        aux1 = (cos((2*pi*vj'*vjj)/(N/4)) - 1i * sin((2*pi*vj'*vjj)/(N/4)));
        aux2 = (cos((2*pi*vjj)/(N/2)) - 1i* sin((2*pi*vjj)/(N/2)));
        aux3 = (cos((2*pi*vjj)/(N)) - 1i * sin((2*pi*vjj)/(N)));
        f = vjj * taxa_amos / N; % Frequências do Espectro
        for i=1:1:terminais_qtde
            if selecao(i)==1 % verifica se foi escolhida para plotar
                figure; hold on
                ii=1;
                taux=t1+N-1;
                while taux < t2
                    %---------------------------------------------------------------------
                    % Cálculo das Componentes em função da Matriz Base (senos e cossenos)
                    A1 = aux1'*sinal(i,t1  :4:taux)';
                    A2 = aux1'*sinal(i,t1+2:4:taux)';
                    B1 = aux1'*sinal(i,t1+1:4:taux)';
                    B2 = aux1'*sinal(i,t1+3:4:taux)';
                    A = A1 + aux2'.*A2;
                    B = B1 + aux2'.*B2;
                    X = A  + aux3'.*B;
                    Xamp     = abs(X); % Cálculo da Amplitude
                    Amp(ii,:) = Xamp*2/N; % "Normaliza a amplitude"
                    vaux(ii)= taux/taxa_amos;
                    t1=t1+passo;
                    taux=taux+passo;
                    ii=ii+1;
                end
                H = surf(vaux',f(Fmin:Fmax)',Amp(:,Fmin:Fmax)'); % Espectro
                shading interp
                colormap('jet')
                title(strcat('Espectro de Frequência - ',sinal_nome,terminal_nome(i,:)))
                zlabel(strcat('Amplitude  [',unidade,']'));
                ylabel('Frequência (Hz)');
                xlabel(tempo_legenda);
                grid on;
                axis([vaux(1) vaux(length(vaux)) Fmin*taxa_amos/N Fmax*taxa_amos/N])
            end
        end
    end
    clear sinal
close(DFT_Janelada)
end



