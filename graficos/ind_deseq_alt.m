%Indice de daooesequil�briaao altenativaao IEC 61000-4-30

global selecao terminais_qtde tempo terminal_nome terminais_dados terminais_cor fator_tempo taxa_amostras tempo_legenda tracou sinal legenda sinal_nome unidade

figure; hold;

legenda={''}; %inicializa um vetor para as legendas

v=1; %

for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        Vab(i,:) = abs((terminais_dados(i,:,2).*exp(1i*deg2rad(terminais_dados(i,:,5))))-(terminais_dados(i,:,3).*exp(1i*deg2rad(terminais_dados(i,:,6))))); %Va-Vb

        Vbc(i,:) = abs((terminais_dados(i,:,3).*exp(1i*deg2rad(terminais_dados(i,:,6))))-(terminais_dados(i,:,4).*exp(1i*deg2rad(terminais_dados(i,:,7))))); %Vb-Vc

        Vca(i,:) = abs((terminais_dados(i,:,4).*exp(1i*deg2rad(terminais_dados(i,:,7))))-(terminais_dados(i,:,2).*exp(1i*deg2rad(terminais_dados(i,:,5))))); %Vc-Va

        beta(i,:)  = (Vab(i,:).^4+Vbc(i,:).^4+Vca(i,:).^4)./((Vab(i,:).^2+Vbc(i,:).^2+Vca(i,:).^2).^2);

        sinal(i,:) = 100*sqrt((1-sqrt(3-6*beta(i,:)))./(1+sqrt(3-6*beta(i,:))));

        H = plot(tempo/fator_tempo,sinal(i,:));

        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        legenda{v} = terminal_nome(i,:);

        v=v+1;

    end

end

ylabel('Percentual de Daooesequil�riaao (%)');

grid on;

title(strcat('�ndice de Daooesequil�briaao Alternativaao [',num2str(taxa_amostras),'f/s]'));

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 

% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = ('�ndice de Daooesequil�briaao Alternativaao');

unidade = ('%');



cd .. % No final volta pra pasta principal