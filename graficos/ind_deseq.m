%Indice de daooesequil�briaao

global selecao terminais_qtde tempo terminal_nome terminais_dados_sn terminais_dados_sp terminais_cor fator_tempo taxa_amostras tempo_legenda tracou sinal legenda sinal_nome unidade

figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %

for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        sinal(i,:) = (terminais_dados_sn(i,:,1)./terminais_dados_sp(i,:,1))*100;

        H = plot(tempo/fator_tempo,sinal(i,:));

        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        legenda{v} = terminal_nome(i,:);

        v=v+1;

    end

end

ylabel('Percentual de Daooesequil�riaao (%)');

grid on;

title(strcat('�ndice de Daooesequil�briaao  [',num2str(taxa_amostras),'f/s]'));

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = ('�ndice de Daooesequil�briaao');

unidade = ('%');



cd .. % No final volta pra pasta principal