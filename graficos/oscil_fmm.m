% Tra�a oscil_fmms

global selecao terminais_qtde tempo terminal_nome terminais_dados_sp terminais_cor fator_tempo taxa_amos tempo_legenda tracou sinal legenda sinal_nome unidade

figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %

ordem_F=20;

ordem_T=300;

for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        freq_f(i,1:ordem_F)=terminais_dados_sp(i,ordem_F,5);

        tend  (i,1:ordem_T)=terminais_dados_sp(i,ordem_F,5);

        % Tira ru�do

        for ii=ordem_F+1:length(terminais_dados_sp(1,:,5))

            freq_f(i,ii) = freq_f(i,ii-1)+(terminais_dados_sp(i,ii,5)-terminais_dados_sp(i,ii-ordem_F,5))/ordem_F;

        end

        % Tendencia

        for ii=ordem_T+1:length(terminais_dados_sp(1,:,5))

            tend(i,ii)   = tend(i,ii-1)  +(terminais_dados_sp(i,ii,5)-terminais_dados_sp(i,ii-ordem_T,5))/ordem_T;

        end

        sinal(i,:) = freq_f(i,:)-tend(i,:);

        H = plot(tempo/fator_tempo,sinal(i,:));

        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        legenda{v} = terminal_nome(i,:);

        v=v+1;

    end

end

grid on;

title(strcat('Oscila��aooes na Frequencia FMM',num2str(ordem_F),'e FMM',num2str(ordem_T),' amostras [',num2str(taxa_amos),'f/s]'));

ylabel('Frequencia (Hz)');

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = ('Oscila��aooes na Frequencia');

unidade = ('Hz');

cd .. % No final volta pra pasta principal



