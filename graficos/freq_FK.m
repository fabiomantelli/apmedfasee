% FilPlotao de Kalman - Tra�a Frequencias Selecionadas

global selecao terminais_qtde tempo terminal_nome terminais_dados_sp terminais_cor fator_tempo taxa_amos tempo_legenda tracou sinal legenda sinal_nome unidade

figure; 

legenda={''}; %inicializa um vetor para as legendas

v=1; %



% Constantes

T=1/taxa_amos;

tauv = 0.005;%(0.005)0.0005 desvio padr�aao da covari�ncia do ru�do medida

% auxi=600; %TENTA CALCULAR O DESVIO PADR�O DE UM INTERVALO DE MEDIDAS

% for i=1:1:terminais_qtde

%     med(i) = sum(terminais_dados_sp(i,1:auxi,5))/auxi;

%     tauv(i) = sqrt(sum((terminais_dados_sp(i,:,5)-med(i)).^2)/(auxi));

% end

alfa = 0.01;   %(0.01)0.02 inversaao da constante de tempo da perturba��aao

amax = 1;    %(0.05) limite de acelera��aao do �ngulaao

% Matriz de transi��aao de estados-------------------------------------------

F = [1 T (-1+(alfa*T)+(exp(-alfa*T)))/(alfa^2) ; 0 1 (1-exp(-alfa*T))/alfa ; 0 0 exp(-alfa*T)];

% Matriz de entrada

U = [(-T + (alfa*(T^2))/2 + (1-exp(-alfa*T))/alfa)/alfa ; T - (1-exp(-alfa*T))/alfa ; 1 - exp(-alfa*T)];

% Matriz de medi��aao

H = [0 1 0];

% Covari�ncia do r�ido do processo-----------------------------------------

q11 = (1/(2*alfa^5))*(1 - exp(-2*alfa*T) + 2*alfa*T + ((2*alfa^3*T^3)/3) - 2*alfa^2*T^2 - 4*alfa*T*exp(-alfa*T));

q12 = (1/(2*alfa^4))*(exp(-2*alfa*T) + 1 - 2*exp(-alfa*T) + 2*alfa*T*exp(-alfa*T) - 2*alfa*T + alfa^2*T^2);

q13 = (1/(2*alfa^3))*(1 - exp(-2*alfa*T) - 2*alfa*T*exp(-alfa*T));

q22 = (1/(2*alfa^3))*(4*exp(-alfa*T) - 3 - exp(-2*alfa*T) + 2*alfa*T);

q23 = (1/(2*alfa^2))*(exp(-2*alfa*T) + 1 - 2*exp(-alfa*T));

q33 = (1/(2*alfa))*(1 - exp(-2*alfa*T));

Q = [q11 q12 q13 ; q12 q22 q23 ; q13 q23 q33];

P1 = [1 T (T^2)/2;0 1 T;0 0 1]; %Matriz para c�lculaao da covari�ncia

X2 = []; X3 = [];     % Vetores de estados



for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        % Covari�ncia do ru�do de medida

        R = tauv^2;

        f(i,:) = terminais_dados_sp(i,:,5);

        xe = [0;f(i,1);0];           % Condi��aao inicial dos estados = 0

        a = 0;                       % Condi��aao inicial da entrada

        x = [0;0;0];

        P = 0;                         % Covari�ncia do erraao inicial

        for ii=1:1:length(terminais_dados_sp(i,:,5))

            % Densidade de Probabilidade

            Ta = ((4-pi)/pi)*(amax-abs(x(3)))^2; % Covari�cia do ru�do do processo

            % Atualiza��aao de Tempaao

            % 1 - Proje��aao do Estado a Priori

            xe = F*xe + U*a;

            % 2 - Proje��aao da Covari�ncia do Erraao a Priori

            P = F*P*F.' + H*(Q*2*alfa*Ta)*H.';

            % Atualiza��aao da Medida

            % 1- Ganho de Kalman

            K = P*H.'/(H*P*H.' + R);

            % 2- Atualiza a estimativa com a medida

            y = H*[0;f(i,ii);0];        % Sinal Medido + Ru�do

            xe = xe + K*(y - H*xe);     % x[n|n]

            % 3- Atualiza��aao da covari�ncia do erraao

            P  = (eye(length(F)) - K*H)*P;

            % Entrada para a pr�xima itera��aao

            x = P1*xe;

            a = x(3);

            % Estados

            X2(i,ii) =  xe(2);

            X3(i,ii) =  xe(3);

        end

        

        % Tra�a os sinais

        sinal(i,:) = X3(i,:); % Frequencia filtrada

        

        ax(1) = subplot (3,1,1);

        H1 = plot(tempo/fator_tempo,terminais_dados_sp(i,:,5));  

        set(H1,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        hold on; 

        

        ax(2) = subplot (3,1,2);

        H2 = plot(tempo/fator_tempo,X2(i,:));  

        set(H2,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        hold on; 

        

        ax(3) = subplot (3,1,3);

        H3 = plot(tempo/fator_tempo,sinal(i,:));  

        set(H3,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        hold on; 

        

        legenda{v} = terminal_nome(i,:);

        v=v+1;

        

        

        

    end

end

% -------------------------------------------------------------------------



% Formatar eixo X automaticamente

auto_format_time_axis();

grid on;



subplot (3,1,2);

title(strcat('Frequencia do SIN (Estimada pelo FK) [',num2str(taxa_amos),'f/s]'));

ylabel('Frequencia (Hz)');

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

auto_format_time_axis();

legend(legenda);

grid on;



subplot (3,1,3);

title(strcat('Acelera��aao Angular (Estimada pelo FK) [',num2str(taxa_amos),'f/s]'));

ylabel('Acelera��aao Angular (Hz/s)');

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

auto_format_time_axis();

grid on;



linkaxes([ax(3) ax(2) ax(1)],'x');



tracou=1;

sinal_nome = ('Acelera��aao Angular Estimada');

unidade = ('Hz\s');



cd .. % No final volta pra pasta principal