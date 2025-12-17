% Script para testar se arquivo .mat contém terminais_frequencia
clear all;
close all;
clc;

arquivo = '20100210_3_subsist.mat';

fprintf('=== TESTE DE TERMINAIS_FREQUENCIA ===\n');
fprintf('Arquivo: %s\n\n', arquivo);

cd('consultas');
try
    % Carregar arquivo
    load(arquivo);
    fprintf('Arquivo carregado com sucesso!\n\n');
    
    % Verificar variáveis carregadas
    fprintf('Variáveis carregadas:\n');
    vars = whos;
    for i = 1:length(vars)
        fprintf('  - %s: %s\n', vars(i).name, mat2str(vars(i).size));
    end
    fprintf('\n');
    
    % Verificar terminais_frequencia especificamente
    if exist('terminais_frequencia', 'var')
        fprintf('✓ terminais_frequencia EXISTE\n');
        fprintf('  Tamanho: %s\n', mat2str(size(terminais_frequencia)));
        
        if ~isempty(terminais_frequencia)
            fprintf('  Não está vazio\n');
            soma_total = sum(terminais_frequencia(:));
            fprintf('  Soma total: %.2f\n', soma_total);
            
            % Verificar se tem valores não-zero
            valores_nao_zero = terminais_frequencia(terminais_frequencia ~= 0);
            fprintf('  Valores não-zero: %d de %d\n', length(valores_nao_zero), numel(terminais_frequencia));
            
            if any(terminais_frequencia(:) ~= 0)
                fprintf('  ✓ TEM valores não-zero\n');
            else
                fprintf('  ✗ TODOS os valores são zero\n');
            end
        else
            fprintf('  ✗ Está VAZIO\n');
        end
    else
        fprintf('✗ terminais_frequencia NÃO EXISTE neste arquivo\n');
    end
    
    cd('..');
    
catch ME
    cd('..');
    fprintf('ERRO ao carregar arquivo: %s\n', ME.message);
end

fprintf('\n=== FIM DO TESTE ===\n');



