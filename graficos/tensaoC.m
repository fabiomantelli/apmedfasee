%Tens�aao_Fase_C

global selecao terminais_qtde tempo terminal_nome terminais_dados terminais_cor fator_tempo taxa_amostras tempo_legenda base_modulaao tracou sinal tracar_pu legenda sinal_nome unidade

figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %



if tracar_pu == 0 

    for i=1:1:terminais_qtde

        if selecao(i)==1 % verifica se foi escolhida para plotar

            % Verificar se terminais_dados tem o tamanho correto
            if ~exist('terminais_dados', 'var') || isempty(terminais_dados) || size(terminais_dados, 1) < i || size(terminais_dados, 3) < 4
                continue;  % Pular este terminal se dados não estiverem disponíveis
            end
            
            sinal(i,:) = terminais_dados(i,:,4);

            H = plot(tempo/fator_tempo,sinal(i,:));

            % Verificar se terminais_cor existe e tem o tamanho correto
            if ~exist('terminais_cor', 'var') || isempty(terminais_cor) || size(terminais_cor, 1) < i
                % Fallback: usar cor padrão se terminais_cor não estiver disponível
                set(H,'Color',[1 0 0],'LineWidth',2);  % Vermelho padrão
            else
                set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);
            end

            % Verificar se terminal_nome existe e tem o tamanho correto
            if ~exist('terminal_nome', 'var') || isempty(terminal_nome) || size(terminal_nome, 1) < i
                legenda{v} = sprintf('Terminal %d', i);
            else
                legenda{v} = terminal_nome(i,:);
            end

            v=v+1;

        end

    end

    ylabel('Tens�aao (V)');

    unidade = ('Volts');

else 

    for i=1:1:terminais_qtde

        if selecao(i)==1 % verifica se foi escolhida para plotar

            % Verificar se terminais_dados tem o tamanho correto
            if ~exist('terminais_dados', 'var') || isempty(terminais_dados) || size(terminais_dados, 1) < i || size(terminais_dados, 3) < 4
                continue;  % Pular este terminal se dados não estiverem disponíveis
            end
            
            % Verificar se base_modulaao existe e tem o tamanho correto
            if ~exist('base_modulaao', 'var') || isempty(base_modulaao) || length(base_modulaao) < i || base_modulaao(i) == 0
                % Fallback: usar valor padrão se base_modulaao não estiver disponível
                sinal(i,:) = terminais_dados(i,:,4);
            else
                sinal(i,:) = terminais_dados(i,:,4)/base_modulaao(i);
            end

            H = plot(tempo/fator_tempo,sinal(i,:));

            % Verificar se terminais_cor existe e tem o tamanho correto
            if ~exist('terminais_cor', 'var') || isempty(terminais_cor) || size(terminais_cor, 1) < i
                % Fallback: usar cor padrão se terminais_cor não estiver disponível
                set(H,'Color',[1 0 0],'LineWidth',2);  % Vermelho padrão
            else
                set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);
            end

            % Verificar se terminal_nome existe e tem o tamanho correto
            if ~exist('terminal_nome', 'var') || isempty(terminal_nome) || size(terminal_nome, 1) < i
                legenda{v} = sprintf('Terminal %d', i);
            else
                legenda{v} = terminal_nome(i,:);
            end

            v=v+1;

        end

    end

    ylabel('Tens�aao (pu)');

    unidade = ('pu');

end

grid on;

title(strcat('M�dulaao da Tens�aao da Fase C  [',num2str(taxa_amostras),'f/s]'));

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou = 1;

sinal_nome = ('M�dulaao da Tens�aao da Fase C');



cd .. % No final volta pra pasta principal