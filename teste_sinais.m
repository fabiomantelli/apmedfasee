% Script para testar estrutura dos arquivos .mat e identificar problemas
cd('consultas');
arquivos = dir('*.mat');
fprintf('=== TESTE DE ESTRUTURA DOS ARQUIVOS .MAT ===\n\n');
fprintf('Encontrados %d arquivos .mat\n\n', length(arquivos));

erros_encontrados = {};

for i = 1:min(10, length(arquivos))
    nome_arquivo = arquivos(i).name;
    fprintf('=== Testando: %s ===\n', nome_arquivo);
    try
        % Limpar variáveis globais antes de carregar
        clear terminais_dados terminais_dados_sp terminais_dados_sn terminais_dados_s0 terminais_frequencia terminais_qtde terminal_nome;
        
        load(nome_arquivo);
        
        if exist('terminais_qtde', 'var')
            fprintf('  terminais_qtde: %d\n', terminais_qtde);
        else
            fprintf('  AVISO: terminais_qtde não encontrado!\n');
            erros_encontrados{end+1} = sprintf('%s: falta terminais_qtde', nome_arquivo);
            continue;
        end
        
        if exist('terminais_dados', 'var')
            fprintf('  terminais_dados: %s\n', mat2str(size(terminais_dados)));
            
            % Verificar tamanhos de cada terminal
            tamanhos_terminais = [];
            for j = 1:terminais_qtde
                tamanho_term = size(terminais_dados, 2);
                tamanhos_terminais(j) = tamanho_term;
                
                % Verificar se há dados válidos
                dados_temp = terminais_dados(j, :, 1);
                dados_validos = dados_temp(~isnan(dados_temp) & dados_temp ~= 0);
                if ~isempty(dados_validos)
                    fprintf('    Terminal %d: tamanho array=%d, dados válidos=%d\n', j, tamanho_term, length(dados_validos));
                end
            end
            
            % Verificar se todos têm o mesmo tamanho
            if length(unique(tamanhos_terminais)) == 1
                fprintf('  OK: Todos os terminais têm o mesmo tamanho: %d\n', tamanhos_terminais(1));
            else
                fprintf('  ERRO: Terminais têm tamanhos diferentes!\n');
                fprintf('  Tamanhos: %s\n', mat2str(tamanhos_terminais));
                erros_encontrados{end+1} = sprintf('%s: tamanhos diferentes entre terminais', nome_arquivo);
            end
            
            % Verificar tamanho do tempo
            if exist('tempo', 'var')
                fprintf('  tempo: tamanho=%d\n', length(tempo));
                if length(tempo) ~= tamanhos_terminais(1)
                    fprintf('  AVISO: tempo tem tamanho diferente dos dados!\n');
                    erros_encontrados{end+1} = sprintf('%s: tempo com tamanho diferente', nome_arquivo);
                end
            end
        else
            fprintf('  AVISO: terminais_dados não encontrado!\n');
        end
        
        if exist('terminais_dados_sp', 'var')
            fprintf('  terminais_dados_sp: %s\n', mat2str(size(terminais_dados_sp)));
        end
        
        if exist('terminais_frequencia', 'var')
            fprintf('  terminais_frequencia: %s\n', mat2str(size(terminais_frequencia)));
        end
        
        fprintf('\n');
        
    catch ME
        fprintf('  ERRO ao carregar: %s\n', ME.message);
        erros_encontrados{end+1} = sprintf('%s: %s', nome_arquivo, ME.message);
    end
end

cd('..');

fprintf('\n=== RESUMO DE ERROS ENCONTRADOS ===\n');
if isempty(erros_encontrados)
    fprintf('Nenhum erro encontrado!\n');
else
    for i = 1:length(erros_encontrados)
        fprintf('%d. %s\n', i, erros_encontrados{i});
    end
end

fprintf('\n=== TESTE DE PLOTAGEM SIMULADA ===\n');
fprintf('Testando se a atribuição sinal(i,:) = terminais_dados(i,:,2) funcionaria...\n\n');

% Testar com o primeiro arquivo que tem terminais_dados
for i = 1:min(5, length(arquivos))
    nome_arquivo = arquivos(i).name;
    try
        clear terminais_dados terminais_qtde selecao tempo;
        cd('consultas');
        load(nome_arquivo);
        cd('..');
        
        if exist('terminais_dados', 'var') && exist('terminais_qtde', 'var')
            fprintf('Testando: %s\n', nome_arquivo);
            fprintf('  terminais_dados: %s\n', mat2str(size(terminais_dados)));
            
            % Simular o que o script tensaoA.m faz
            selecao = zeros(1, terminais_qtde);
            selecao(1) = 1; % Selecionar primeiro terminal
            
            % Tentar fazer a atribuição que causa erro
            try
                sinal = [];
                for j = 1:terminais_qtde
                    if selecao(j) == 1
                        sinal(j,:) = terminais_dados(j,:,2);
                        fprintf('  OK: Atribuição sinal(%d,:) = terminais_dados(%d,:,2) funcionou\n', j, j);
                        fprintf('    sinal agora tem tamanho: %s\n', mat2str(size(sinal)));
                    end
                end
                
                % Tentar com segundo terminal se existir
                if terminais_qtde > 1
                    selecao(2) = 1;
                    try
                        sinal(2,:) = terminais_dados(2,:,2);
                        fprintf('  OK: Atribuição sinal(2,:) = terminais_dados(2,:,2) funcionou\n');
                    catch ME2
                        fprintf('  ERRO ao atribuir segundo terminal: %s\n', ME2.message);
                        fprintf('    Tamanho sinal(1,:): %d\n', size(sinal, 2));
                        fprintf('    Tamanho terminais_dados(2,:,2): %d\n', size(terminais_dados, 2));
                    end
                end
            catch ME3
                fprintf('  ERRO na simulação: %s\n', ME3.message);
            end
            fprintf('\n');
        end
    catch ME
        fprintf('  Erro ao testar %s: %s\n\n', nome_arquivo, ME.message);
    end
end

fprintf('Teste concluído!\n');



