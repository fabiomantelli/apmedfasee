% Tra�a Frequencias Selecionadas

global selecao terminais_qtde tempo terminal_nome terminais_dados_sp terminais_cor fator_tempo taxa_amostras tempo_legenda tracou sinal legenda sinal_nome unidade

% C�lculaao do rocof

for i=1:1:terminais_qtde

    rocof(i,1) = 0;

    for ii=2:length(terminais_dados_sp(1,:,5))

        rocof(i,ii) = (terminais_dados_sp(i,ii,5) - terminais_dados_sp(i,ii-1,5))*60;

    end

end



figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %

for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        sinal(i,:) = rocof(i,:);

        H = plot(tempo/fator_tempo,sinal(i,:));  

        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        legenda{v} = terminal_nome(i,:);

        v=v+1;

    end

end

grid on;

title(strcat('ROCOF (Calculado) [',num2str(taxa_amostras),'f/s]'));

ylabel('(Hz/s)');

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = ('ROCOF (Calculado)');

unidade = ('(Hz/s)');



cd .. % No final volta pra pasta principal