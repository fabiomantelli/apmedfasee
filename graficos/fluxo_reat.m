% Fluxaao de Pot�ncia Reativa Trif�sica Total

global selecao terminais_qtde tempo terminal_nome terminais_dados fator_tempo taxa_amostras tempo_legenda tem_corrente tracou sinal_nome unidade legendaterminais_cor

if (selecao*tem_corrente')>=1 % verifica se os terminais selecionados possuem corrente

    figure; hold on; grid on;

    legenda={''}; %inicializa um vetor para as legendas

    v=1; %

    for i=1:1:terminais_qtde

        if selecao(i)==1 && tem_corrente(i)==1 % verifica se foi escolhida para plotar e se tem corrente

            sinal(i,:) = (terminais_dados(i,:,2).*terminais_dados(i,:,8).*sin((terminais_dados(i,:,5) - terminais_dados(i,:,11))*2*pi/360))/1E6...

                + (terminais_dados(i,:,3).*terminais_dados(i,:,9).*sin((terminais_dados(i,:,6) - terminais_dados(i,:,12))*2*pi/360))/1E6...

                + (terminais_dados(i,:,4).*terminais_dados(i,:,10).*sin((terminais_dados(i,:,7)- terminais_dados(i,:,13))*2*pi/360))/1E6;

            

            H = plot(tempo/fator_tempo,sinal(i,:));

            set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

            legenda{v} = terminal_nome(i,:);

            v=v+1;

        end

    end

    

    ylabel('Pot�ncia Reativa (MVAr)');

    title(strcat('Fluxaao de Pot�ncia Reativa Trif�sica Total [',num2str(taxa_amostras),'f/s]'));

    xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

% Formatar eixo X automaticamente

auto_format_time_axis();

    legend(legenda);

    tracou = 1;

    sinal_nome = ('Fluxaao de Pot�ncia Reativa Trif�sica Total');

    unidade = ('MVAr');

end

cd .. % No final volta pra pasta principal