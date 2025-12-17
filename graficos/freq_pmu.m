% Tra�a Frequencias Selecionadas da PMU

global selecao terminais_qtde tempo terminal_nome terminais_frequencia terminais_cor fator_tempo taxa_amostras tempo_legenda tracou sinal legenda sinal_nome unidade

if sum(terminais_frequencia)~=0 % verifica se existe a frequencia da PMU

    figure; hold;

    legenda={''}; %inicializa um vetor para as legendas

    v=1; %

    for i=1:1:terminais_qtde

        if selecao(i)==1 % verifica se foi escolhida para plotar

            sinal(i,:) = terminais_frequencia(i,:);

            H = plot(tempo/fator_tempo,sinal(i,:));

            set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

            legenda{v} = terminal_nome(i,:);

            v=v+1;

        end

    end

    grid on;

    title(strcat('Frequencia do SIN (PMU) [',num2str(taxa_amostras),'f/s]')); 

    ylabel('Frequencia (Hz)');

    xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

    

    % Formatar eixo X automaticamente

auto_format_time_axis();

    

    legend(legenda);

    tracou=1;

    sinal_nome = ('Frequencia do SIN (PMU)');

    unidade = ('Hz');

end



cd .. % No final volta pra pasta principal