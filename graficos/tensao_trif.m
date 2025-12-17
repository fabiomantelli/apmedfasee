%Tens�aao_Trif�sica

global selecao terminais_qtde tempo terminal_nome terminais_dados fator_tempo taxa_amostras tempo_legenda base_modulaao tracou sinal tracar_pu sinal_nome unidade



if tracar_pu == 0

    for i=1:1:terminais_qtde

        if selecao(i)==1 % verifica se foi escolhida para plotar

            % Verificar se terminais_dados tem o tamanho correto
            if ~exist('terminais_dados', 'var') || isempty(terminais_dados) || size(terminais_dados, 1) < i || size(terminais_dados, 3) < 4
                continue;  % Pular este terminal se dados não estiverem disponíveis
            end
            
            figure; hold on; grid on;

            sinal(i,:,1) = terminais_dados(i,:,2);

            sinal(i,:,2) = terminais_dados(i,:,3);

            sinal(i,:,3) = terminais_dados(i,:,4);

            

            plot(tempo/fator_tempo,sinal(i,:,1),'r','LineWidth',2);

            plot(tempo/fator_tempo,sinal(i,:,2),'b','LineWidth',2);

            plot(tempo/fator_tempo,sinal(i,:,3),'g','LineWidth',2);

            

            title(strcat('M�dulaao da Tens�aao Trif�sica da PMU-',terminal_nome(i,:),' [',num2str(taxa_amostras),'f/s]'));

            ylabel('Tens�aao (V)');

            xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

% Formatar eixo X automaticamente

auto_format_time_axis();

            legend('Fase A','Fase B','Fase C');

            xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

        end

    end

    unidade = ('Volts');

else

    for i=1:1:terminais_qtde

        if selecao(i)==1 % verifica se foi escolhida para plotar

            % Verificar se terminais_dados tem o tamanho correto
            if ~exist('terminais_dados', 'var') || isempty(terminais_dados) || size(terminais_dados, 1) < i || size(terminais_dados, 3) < 4
                continue;  % Pular este terminal se dados não estiverem disponíveis
            end
            
            figure; hold on; grid on;

            

            % Verificar se base_modulaao existe e tem o tamanho correto
            if ~exist('base_modulaao', 'var') || isempty(base_modulaao) || length(base_modulaao) < i || base_modulaao(i) == 0
                % Fallback: usar valor padrão se base_modulaao não estiver disponível
                sinal(i,:,1) = terminais_dados(i,:,2);
                sinal(i,:,2) = terminais_dados(i,:,3);
                sinal(i,:,3) = terminais_dados(i,:,4);
            else
                sinal(i,:,1) = terminais_dados(i,:,2)/base_modulaao(i);
                sinal(i,:,2) = terminais_dados(i,:,3)/base_modulaao(i);
                sinal(i,:,3) = terminais_dados(i,:,4)/base_modulaao(i);
            end

            

            plot(tempo/fator_tempo,sinal(i,:,1),'r','LineWidth',2);

            plot(tempo/fator_tempo,sinal(i,:,2),'b','LineWidth',2);

            plot(tempo/fator_tempo,sinal(i,:,3),'g','LineWidth',2);

            

            title(strcat('M�dulaao da Tens�aao Trif�sica da PMU-',terminal_nome(i,:),' [',num2str(taxa_amostras),'f/s]'));

            ylabel('Tens�aao (pu)');

            xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

% Formatar eixo X automaticamente

auto_format_time_axis();

            legend('Fase A','Fase B','Fase C');

            xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)])

        end

    end

    unidade = ('pu');

end

tracou=1;

sinal_nome=('M�dulaao da Tens�aao Trif�sica da PMU-');



cd .. % No final volta pra pasta principal