%Tens�aao_Sequ�ncia Negativa

global selecao terminais_qtde tempo terminal_nome terminais_dados_sn terminais_cor fator_tempo taxa_amostras tempo_legenda tracar_pu base_modulaao tracou sinal legenda sinal_nome unidade

figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %

if tracar_pu == 0 

    for i=1:1:terminais_qtde

        if selecao(i)==1 % verifica se foi escolhida para plotar

            % Verificar se terminais_dados_sn tem o tamanho correto
            if ~exist('terminais_dados_sn', 'var') || isempty(terminais_dados_sn) || size(terminais_dados_sn, 1) < i || size(terminais_dados_sn, 3) < 1
                continue;  % Pular este terminal se dados não estiverem disponíveis
            end
            
            sinal(i,:) = terminais_dados_sn(i,:,1);

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

            % Verificar se terminais_dados_sn tem o tamanho correto
            if ~exist('terminais_dados_sn', 'var') || isempty(terminais_dados_sn) || size(terminais_dados_sn, 1) < i || size(terminais_dados_sn, 3) < 1
                continue;  % Pular este terminal se dados não estiverem disponíveis
            end
            
            % Verificar se base_modulaao existe e tem o tamanho correto
            if ~exist('base_modulaao', 'var') || isempty(base_modulaao) || length(base_modulaao) < i || base_modulaao(i) == 0
                % Fallback: usar valor padrão se base_modulaao não estiver disponível
                sinal(i,:) = terminais_dados_sn(i,:,1);
            else
                sinal(i,:) = terminais_dados_sn(i,:,1)/base_modulaao(i);
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

title(strcat('M�dulaao da Tens�aao de Sequ�ncia Negativa  [',num2str(taxa_amostras),'f/s]'));

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = ('M�dulaao da Tens�aao de Sequ�ncia Negativa');



cd .. % No final volta pra pasta principal