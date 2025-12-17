% Traça Frequencias Selecionadas
global selecao terminais_qtde tempo terminal_nome terminais_dados_sp terminais_cor fator_tempo taxa_amos tempo_legenda tracou sinal legenda sinal_nome unidade
figure; hold;
legenda={''}; %inicializa um vetor para as legendas
v=1; %
for i=1:1:terminais_qtde
    if selecao(i)==1 % verifica se foi escolhida para plotar
        sinal(i,:) = terminais_dados_sp(i,:,5);
        H = plot(tempo/fator_tempo,sinal(i,:));  
        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);
        legenda{v} = terminal_nome(i,:);
        v=v+1;
    end
end
grid on;
title(strcat('Frequencia do SIN (Calculada) [',num2str(taxa_amos),'f/s]'));
ylabel('Frequencia (Hz)');
xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente
auto_format_time_axis();

legend(legenda);
tracou=1;
sinal_nome = ('Frequencia do SIN (Calculada)');
unidade = ('Hz');

cd .. % No final volta pra pasta principal
