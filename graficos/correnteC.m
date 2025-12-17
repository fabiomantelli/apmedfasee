%Corrente_Fase_C

global selecao terminais_qtde tempo terminal_nome terminais_dados terminais_cor fator_tempo taxa_amostras tempo_legenda tem_corrente tracou sinal legenda sinal_nome unidade

if (selecao*tem_corrente')>=1 % verifica se os terminais selecionados possuem corrente

    figure; hold;

    legenda={''}; %inicializa um vetor para as legendas

    v=1; %

    for i=1:1:terminais_qtde

        if selecao(i)==1 && tem_corrente(i)==1 % verifica se foi escolhida para plotar e se tem corrente

            sinal(i,:) = terminais_dados(i,:,10);

            H = plot(tempo/fator_tempo,sinal(i,:));

            set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

            legenda{v} = terminal_nome(i,:);

            v=v+1;

        end

    end

    

    grid on;

    title(strcat('M�dulaao da Corrente da Fase C  [',num2str(taxa_amostras),'f/s]'));

    xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

% Formatar eixo X automaticamente

auto_format_time_axis();

    ylabel('Corrente (A)');

    legend(legenda);

    tracou=1;

    sinal_nome = ('M�dulaao da Corrente da Fase C');

    unidade = ('Amperaooes');

end

cd .. % No final volta pra pasta principal