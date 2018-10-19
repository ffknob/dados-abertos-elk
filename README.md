# Dados Abertos com ELK

Este projeto tem o objetivo de facilitar a utilização de conjuntos de dados abertos, fazendo uso da stack _ELK_ (_Elasticsearch + Logstash + Kibana_), que é uma solução baseada em software livre que permite facilmente consumir fontes de dados, manipular/transformar/enriquecer esses dados, indexá-los e, por fim, visualizá-los em dashboards. 

_TL;DR_

1. Baixar os datasets de dados abertos desejados
1. Instalar o Elasticsearch, Kibana e Logstash
1. Executar o Elasticsearch ([http://localhost:9200/](http://localhost:9200)) e Kibana ([http://localhost:5601/](http://localhost:5601/))
1. Executar no Logstash os pipelines para os dicionários
1. Executar no Logstash os pipelines para os conjuntos de dados abertos desejados
1. Configurar no Kibana os Index Patterns dos conjuntos de dados desejados
1. Instalar no Kibana as Visualizations dos conjuntos de dados desejados
1. Instalar no Kibana os Dashboards dos conjuntos de dados desejados

## Download dos conjuntos de dados

O primeiro passo é realizar o download dos arquivos de dados. Eles poderão ser obtidos nos portais de dados abertos dos órgãos. Os arquivos deverão ser salvos nas respectivas pastas, conforme indicado para cada fonte de dados. 

## ELK


### Elasticsearch

O _Elasticsearch_ é o componente central da stack _ELK_ e é responsável por indexar os dados e fornecer uma API REST para a realização de consultas. 

#### Instalação e execução



#### Mappings

O _Elasticsearch_ é capaz de identificar dinamicamente os tipos de dados enviados para a API e indexação, porém, em alguns casos é necessário informar explicitamente, durante a criação do índice, o tipo de dados do campo. Isso é necessário especialmente para campos do tipo _geopoint_ (nos quais a latitude e longitude são informadas separadas por uma vírgula).

O mapeamento deve ser realizado antes da execução do pipeline do _Logstash_, pois uma ves criado o índice, o mapeamento do tipo de dado do campo não poderá ser alterado. Para realizar o mapeamento siga os seguintes passos:

1. Acesse o [http://localhost:5601/app/kibana#/dev_tools/console?_g=()](DevTools no Console do Kibana)
1. Copie o conteúdo do arquivo de mapeamento do conjunto de dados desejado e cole no console
1. Os arquivos são formados por dois comandos: o primeiro irá excluir o índice (caso exista) e o segundo ira criá-lo, já com os mapeamentos de campos necessários

Os índices que precisam ser mapeados são:
 
- _mappings/tcers/balancete-despesa.mapping_
- _mappings/tcers/balancete-receita.mapping_
- _mappings/tcers/diarias-pagas.mapping_

### Logstash

#### Instalação e execução

Executando:

`$ ${LOGSTASH_BASE_DIR}/bin/logstash -f arquivo_configuracao_pipeline.conf`

Como o _Logstash_ mantém o canal de entrada aberto esperando receber mais eventos, ele não encerra a execução mesmo após consumir todo o arquivo (ele espera que mais eventos sejam adicionados ao arquivo). Portanto, ele precisará ser interrompido manualmente. Para isso, aguarde até que ele não esteja mais gerando a saída _dots_ (ele irá gerar um "." para cada evento consumido) e utilize CTRL+C para interrompê-lo.

#### Dicionários 

Os dicionários são utilizados para enriquecer os conjuntos de dados. Cada dicionário é indexado por uma chave simples, que será utilizada por pipelines do _Logstash_ para encontrar o registro que enriquecerá o evento do conjunto de dados.

Os dicionários são arquivos _Yaml_ gerados também com o uso do _Logstash_. Para gerar os dicionários basta executar o _Logstash_ informando o arquivo de configuração do pipeline de cada dicionário.

Os dicionários que deverão ser gerados, obedecendo a ordem, são:

- _auxiliares/dict/municipios.conf_
- _pipeline/tcers/dict/municipios.conf_
- _pipeline/tcers/dict/funcoes.conf_

### Kibana 

#### Instalação e execução

#### Index Patterns

- tcers-balancete-despesa,tcers-balancete-receita
- tcers-lai
- tcers-diarias-pagas
- tcers-decisoes

#### Visualizations

- contabil.visualizations
- lai.visualizations
- diarias-pagas.visualizations
- decisoes.visualizations

#### Dashboards

- contabil.dashboard
- lai.dashboard
- diarias-pagas.dashboard
- decisoes.dashboard

---

### Fonte: Portal de Dados Abertos do TCE-RS

- [Portal de Dados Abertos do TCE-RS](https://dados.tce.rs.gov.br)

#### Auxiliares

_data/tcers/auxiliares/_:

- [http://dados.tce.rs.gov.br/dados/auxiliar/funcoes.csv](http://dados.tce.rs.gov.br/dados/auxiliar/funcoes.csv)
- [http://dados.tce.rs.gov.br/dados/auxiliar/subfuncoes.csv](http://dados.tce.rs.gov.br/dados/auxiliar/subfuncoes.csv)
- [http://dados.tce.rs.gov.br/dados/auxiliar/tipos_unidades.csv](http://dados.tce.rs.gov.br/dados/auxiliar/tipos_unidades.csv)
- [http://dados.tce.rs.gov.br/dados/auxiliar/elementos_de_despesa.csv](http://dados.tce.rs.gov.br/dados/auxiliar/elementos_de_despesa.csv)
- [http://dados.tce.rs.gov.br/dados/auxiliar/modalidade_de_aplicacao.csv](http://dados.tce.rs.gov.br/dados/auxiliar/modalidade_de_aplicacao.csv)
- [http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv](http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv)
- [http://dados.tce.rs.gov.br/dados/auxiliar/municipios.csv](http://dados.tce.rs.gov.br/dados/auxiliar/municipios.csv)

#### Conjuntos de dados

- _data/tcers/balancete-despesa/_: [http://dados.tce.rs.gov.br/dados/municipal/balancete-despesa/](http://dados.tce.rs.gov.br/dados/municipal/balancete-despesa/)
- _data/tcers/balancete-receita/_: [http://dados.tce.rs.gov.br/dados/municipal/balancete-receita/](http://dados.tce.rs.gov.br/dados/municipal/balancete-receita/)
- _data/tcers/solicitacoes-informacao/_: [http://dados.tce.rs.gov.br/dados/lai/solicitacoes-de-informacao/](http://dados.tce.rs.gov.br/dados/lai/solicitacoes-de-informacao/)
- _data/tcers/diarias-pagas/_: [http://dados.tce.rs.gov.br/dados/institucional/diarias-pagas/](http://dados.tce.rs.gov.br/dados/institucional/diarias-pagas/)
- _data/tcers/decisoes/_: [http://dados.tce.rs.gov.br/dados/decisoes/](http://dados.tce.rs.gov.br/dados/decisoes/)

### Fonte: #Datapoa - Portal de Dados Abertos da Prefeitura de Porto Alegre

#### Conjuntos de dados

...
