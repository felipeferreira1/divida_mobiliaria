#Definindo diret�rios a serem utilizados
#getwd()
#setwd("C:\\Users\\User\\Downloads")

#Carregando pacotes que ser�o utilizados
library(reshape2)
library(dplyr)
library(ggplot2)
library(ggrepel)

#Criando fun��o para coleta de s�ries
coleta_dados_sgs = function(series,datainicial="01/01/2000", datafinal = format(Sys.time(), "%d/%m/%Y")){
  #Argumentos: vetor de s�ries, datainicial que pode ser manualmente alterada e datafinal que automaticamente usa a data de hoje
  #Cria estrutura de repeti��o para percorrer vetor com c�digos de s�ries e depois juntar todas em um �nico dataframe
  for (i in 1:length(series)){
    dados = read.csv(url(paste("http://api.bcb.gov.br/dados/serie/bcdata.sgs.",series[i],"/dados?formato=csv&dataInicial=",datainicial,"&dataFinal=",datafinal,sep="")),sep=";")
    dados[,-1] = as.numeric(gsub(",",".",dados[,-1])) #As colunas do dataframe em objetos num�ricos exceto a da data
    nome_coluna = series[i] #Nomeia cada coluna do dataframe com o c�digo da s�rie
    colnames(dados) = c('data', nome_coluna)
    nome_arquivo = paste("dados", i, sep = "") #Nomeia os v�rios arquivos intermedi�rios que s�o criados com cada s�rie
    assign(nome_arquivo, dados)
    
    if(i==1)
      base = dados1 #Primeira repeti��o cria o dataframe
    else
      base = merge(base, dados, by = "data", all = T) #Demais repeti��es agregam colunas ao dataframe criado
    print(paste(i, length(series), sep = '/')) #Printa o progresso da repeti��o
  }
  
  base$data = as.Date(base$data, "%d/%m/%Y") #Transforma coluna de data no formato de data
  base = base[order(base$data),] #Ordena o dataframe de acordo com a data
  return(base)
}

#Coletando dados
serie1 <- c(4173, 4174, 4175, 4176, 4177, 4178, 4179, 4180, 12001, 12002)
part <- coleta_dados_sgs(serie1)

#Renomeando dados
nomes <- c("Data", "C�mbio", "TR", "IGP-M", "IGP-DI", "Over/Selic", "Prefixado", "TJLP", "Outros", "IPCA", "INPC")
colnames(part) <- nomes

#Criando vari�veis extras
part$Infla��o <- part$`IGP-M` + part$`IGP-DI` + part$IPCA + part$INPC
part$Taxas <- part$TR + part$TJLP + part$Outros

#Criando gr�ficos
part_graf1 <- part[,c(1, 2, 6, 7, 12, 13)]

part_graf1 <- melt(part_graf1, id.vars="Data")

ultimo_dado <- part_graf1 %>% group_by(variable) %>% top_n(1, Data) 

graf_total1 <- ggplot(part_graf1, aes(Data, value, label = value, col=variable)) + 
  geom_line(size = 2) + theme_minimal() + theme(legend.position = "bottom") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y", ) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Data", y = "%", title = "D�vida mobili�ria federal: % por indexador (posi��o em carteira)",
       subtitle = "Fonte: BCB", colour = "Data de vencimento") + 
  geom_label_repel(data = ultimo_dado, size = 3, show.legend = F)

#ggsave("divida_mobiliaria1.png", graf_total1)

part_graf2 <- part[,c(1, 6, 7, 12)]

part_graf2 <- melt(part_graf2, id.vars="Data")

ultimo_dado <- part_graf2 %>% group_by(variable) %>% top_n(1, Data) 

graf_total2 <- ggplot(part_graf2, aes(Data, value, label = value, col=variable)) + 
  geom_line(size = 2) + theme_minimal() + theme(legend.position = "bottom") +
  scale_x_date(date_breaks = "1 year", date_labels = "%Y", ) + 
  theme(axis.text.x = element_text(angle = 90, hjust = 1)) +
  labs(x = "Data", y = "%", title = "D�vida mobili�ria federal: % por indexador (posi��o em carteira)", 
       subtitle = "Fonte: BCB", colour = "Data de vencimento") + 
  geom_label_repel(data = ultimo_dado, size = 3, show.legend = F)

#ggsave("divida_mobiliaria2.png", graf_total2)