% Fluxaao de Pot�ncia Aparente Trif�sicaao

global selecao terminais_qtde tempo terminal_nome terminais_dados fator_tempo taxa_amostras tempo_legenda tem_corrente tracou sinal_nome unidade legenda terminais_cor

if (selecao*tem_corrente')>=1 % verifica se os terminais selecionados possuem corrente

    figure; hold on; grid on;

    legenda={''}; %inicializa um vetor para as legendas

    v=1; %

    for i=1:1:terminais_qtde

        if selecao(i)==1 && tem_corrente(i)==1 % verifica se foi escolhida para plotar e se tem corrente

           sinal(i,:)=(terminais_dados(i,:,2).*terminais_dados(i,:,8))/1E6...

            +(terminais_dados(i,:,3).*terminais_dados(i,:,9))/1E6...

            +(terminais_dados(i,:,4).*terminais_dados(i,:,10))/1E6;

            

            H = plot(tempo/fator_tempo,sinal(i,:));

            set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

            legenda{v} = terminal_nome(i,:);

            v=v+1;

        end

    end

    ylabel('Pot�ncia Aparente (MVA)');

    title(strcat('Fluxaao de Pot�ncia Aparente Trif�sica Total [',num2str(taxa_amostras),'f/s]'));

    xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

% Formatar eixo X automaticamente

auto_format_time_axis();

    legend(legenda);

    tracou = 1;

    sinal_nome = ('Fluxaao de Pot�ncia Aparente Trif�sica Total');

    unidade = ('MVA');

end

cd .. % No final volta pra pasta principal