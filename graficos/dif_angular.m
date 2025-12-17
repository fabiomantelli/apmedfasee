% Tra�a diferen�as angulataooes

global selecao terminais_qtde terminais_dados tempo terminal_nome terminais_dados_sp terminais_cor fator_tempo taxa_amostras tempo_legenda ref_sel tracou sinal legenda sinal_nome unidade

% Procaooessamentaao das diferen�as angularaooes

for i=1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        for ii=1:length(terminais_dados_sp(1,:,1))

            dif(i,ii) =terminais_dados_sp(i,ii,2)-terminais_dados_sp(ref_sel,ii,2);

            % Taooesta se � ponto faltante

            if (terminais_dados(ref_sel,ii,14)==1 || terminais_dados(i,ii,14)==1) && ii>1

                dif(i,ii) = dif(i,ii-1);

            end

            % faz aao "empacotamentaao" do angular

            if dif(i,ii) > 180

               dif(i,ii) = dif(i,ii) - 360;

            elseif dif(i,ii) < -180

               dif(i,ii) = dif(i,ii) + 360;

            end;

        end;

    end

end



figure; hold; v=1;legenda={''}; %inicializa um vetor para as legendas

for i=1:1:terminais_qtde

    if selecao(i)==1 % verifica se foi escolhida para plotar

        sinal(i,:) = dif(i,:);

        H = plot(tempo/fator_tempo,sinal(i,:));

        set(H,'Color',str2num(terminais_cor(i,:)),'LineWidth',2);

        legenda{v} = terminal_nome(i,:);

        v=v+1;

    end

end



ylabel('Diferen�a Angular (graus)');

grid on;

title(strcat('Diferen�a Angular - Refer�ncia (',terminal_nome(ref_sel,:),') [',num2str(taxa_amostras),'f/s]'));

xlim([min(tempo/fator_tempo) max(tempo/fator_tempo)]) 



% Formatar eixo X automaticamente

auto_format_time_axis();

legend(legenda);

tracou=1;

sinal_nome = strcat('Diferen�a Angular - Refer�ncia (',terminal_nome(ref_sel,:),')');

unidade = ('Graus');

cd .. % No final volta pra pasta principal    