% Tra�a Frequencias Filtradas

global selecao terminais_qtde tempo terminal_nome terminais_dados_sp terminais_cor fator_tempo taxa_amostras tempo_legenda tracou sinal legenda sinal_nome unidade

figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %



%define aao n�meraao de refer�ncia

ref=0.05;

% Verifica a Frequencia atual e a anterior

for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        freq(i,:)=terminais_dados_sp(i,:,5);

        for ii=2:length(terminais_dados_sp(1,:,5))

            dif_freq= abs(freq(i,ii)-freq(i,ii-1));

            if dif_freq > ref

                freq(i,ii) = freq(i,ii-1);

            else

                freq(i,ii) = freq(i,ii);

            end

        end

        H = plot(tempo/fator_tempo,freq(i,:));

        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        legenda{v} = terminal_nome(i,:);

        v=v+1;

    end

end



% se dif_freq>ref //verifica se existe um ponto fora da faixa

% freq[n]=(freq[n-2]+freq[n-1])/2

% % verificar a diferen�a angular desejada do ponto [n-1] para aao ponto [n] // que raooesulte na freq[n], corrigindo aao �ngulaao naao instante [n].

% dif_ang_desejada = (freq[n] - 60.0) * 6;

% angular[n]=angular[n-1]+dif_ang_desejada;

% sen�aao

% % n�aao faz nada

% fim se

% n=n+1;

% retorna laaoop;





% for i=1:1:terminais_qtde

%     if selecao(i)==1 % verifica se foi escolhida para plotar

%         sinal(i,1:ordem_F)=terminais_dados_sp(i,ordem_F,5);

%         for ii=ordem_F+1:length(terminais_dados_sp(1,:,5))

%             sinal(i,ii) = sinal(i,ii-1)+(terminais_dados_sp(i,ii,5)-terminais_dados_sp(i,ii-ordem_F,5))/ordem_F;

%         end

%         H = plot(tempo/fator_tempo,sinal(i,:));

%         set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

%         legenda{v} = terminal_nome(i,:);

%         v=v+1;

%     end

% end

grid on;

title(strcat('Frequencia do SIN (OOB) - [',num2str(taxa_amostras),'f/s]'));

ylabel('Frequencia (Hz)');

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = ('Frequencia do SIN (Calculada)');

unidade = ('Hz');

cd .. % No final volta pra pasta principal



