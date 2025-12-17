% Fluxaao de Pot�ncia Reativa Trif�sica

global selecao terminais_qtde tempo terminal_nome terminais_dados fator_tempo taxa_amostras tempo_legenda tem_corrente tracou sinal_nome unidade

if (selecao*tem_corrente')>=1 % verifica se os terminais selecionados possuem corrente

    legenda={''}; %inicializa um vetor para as legendas

    v=1; %

    for i=1:1:terminais_qtde

        if selecao(i)==1 && tem_corrente(i)==1 % verifica se foi escolhida para plotar e se tem corrente

            figure; hold on; grid on;

            sinal(i,:,1) = (terminais_dados(i,:,2).*terminais_dados(i,:,8).*sin((terminais_dados(i,:,5)-terminais_dados(i,:,11))*2*pi/360))/1E6;

            sinal(i,:,2) = (terminais_dados(i,:,3).*terminais_dados(i,:,9).*sin((terminais_dados(i,:,6)-terminais_dados(i,:,12))*2*pi/360))/1E6;

            sinal(i,:,3) = (terminais_dados(i,:,4).*terminais_dados(i,:,10).*sin((terminais_dados(i,:,7)-terminais_dados(i,:,13))*2*pi/360))/1E6;



            plot(tempo/fator_tempo,sinal(i,:,1),'r','LineWidth',2);

            plot(tempo/fator_tempo,sinal(i,:,2),'b','LineWidth',2);

            plot(tempo/fator_tempo,sinal(i,:,3),'g','LineWidth',2);

            

            title(strcat('Fluxaao de Pot�ncia Reativa Trif�sica do Terminal-',terminal_nome(i,:),' [',num2str(taxa_amostras),'f/s]'));

            ylabel('Pot�ncia Reativa (MVAr)');

            xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

% Formatar eixo X automaticamente

auto_format_time_axis();

            legend('Fase A','Fase B','Fase C');

            xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

        end

    end

    tracou = 1;

    sinal_nome = ('Fluxaao de Pot�ncia Reativa Trif�sica do Terminal-');

    unidade = ('MVAr');

end

cd .. % No final volta pra pasta principal