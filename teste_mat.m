% Script para testar estrutura dos arquivos .mat
cd('consultas');
arquivos = dir('*.mat');
fprintf('Encontrados %d arquivos .mat\n\n', length(arquivos));

for i = 1:min(5, length(arquivos))
    nome_arquivo = arquivos(i).name;
    fprintf('=== Testando: %s ===\n', nome_arquivo);
    try
        load(nome_arquivo);
        
        if exist('terminais_dados', 'var')
            fprintf('  terminais_dados: %s\n', mat2str(size(terminais_dados)));
            % Verificar se todos os terminais têm o mesmo tamanho
            tamanhos = [];
            for j = 1:terminais_qtde
                tamanhos(j) = size(terminais_dados, 2);
            end
            if length(unique(tamanhos)) == 1
                fprintf('  Todos os terminais têm o mesmo tamanho: %d\n', tamanhos(1));
            else
                fprintf('  AVISO: Terminais têm tamanhos diferentes!\n');
                fprintf('  Tamanhos: %s\n', mat2str(tamanhos));
            end
        end
        
        if exist('terminais_dados_sp', 'var')
            fprintf('  terminais_dados_sp: %s\n', mat2str(size(terminais_dados_sp)));
        end
        
        if exist('terminais_frequencia', 'var')
            fprintf('  terminais_frequencia: %s\n', mat2str(size(terminais_frequencia)));
        end
        
        if exist('terminais_qtde', 'var')
            fprintf('  terminais_qtde: %d\n', terminais_qtde);
        end
        
        fprintf('\n');
        clear terminais_dados terminais_dados_sp terminais_dados_sn terminais_dados_s0 terminais_frequencia terminais_qtde terminal_nome;
    catch ME
        fprintf('  ERRO ao carregar: %s\n', ME.message);
    end
end

cd('..');



