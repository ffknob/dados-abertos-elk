# Dados Abertos com Elastic Stack (ELK)

Este projeto tem o objetivo de facilitar a utilização de conjuntos de dados abertos, fazendo uso da stack _ELK_ (_Elasticsearch + Logstash + Kibana_), que é uma solução baseada em software livre que permite facilmente consumir fontes de dados, manipular/transformar/enriquecer esses dados, indexá-los e, por fim, visualizá-los em dashboards. 

_TL;DR_

1. Baixar os conjuntos de dados abertos desejados
1. Instalar o _Elasticsearch_, _Kibana_ e _Logstash_
1. Executar o _Elasticsearch_ ([http://localhost:9200/](http://localhost:9200)) e _Kibana_ ([http://localhost:5601/](http://localhost:5601/))
1. _Opcional_: Executar no _Logstash_ os pipelines para os dicionários
1. Executar no _Logstash_ os pipelines para os conjuntos de dados abertos desejados
1. Configurar no _Kibana_ os Index Patterns dos conjuntos de dados desejados
1. Instalar no _Kibana_ as Visualizations dos conjuntos de dados desejados
1. Instalar no _Kibana_ os Dashboards dos conjuntos de dados desejados

## Conjuntos de dados

O primeiro passo é realizar o download dos conjuntos de dados. Eles poderão ser obtidos nos portais de dados abertos dos órgãos. Os arquivos deverão ser salvos nas respectivas pastas, conforme indicado na tabela _Fontes de dados abertos_. 

## Dicionários 

Os dicionários são utilizados para enriquecer os conjuntos de dados. Cada dicionário é indexado por uma chave simples, que será utilizada por pipelines do _Logstash_ para encontrar o registro que enriquecerá o evento do conjunto de dados.

Os dicionários são arquivos _Yaml_ gerados também com o uso do _Logstash_. Para gerar os dicionários basta executar o _Logstash_ informando o arquivo de configuração do pipeline de cada dicionário.

Os dicionários que serão utilizados para enriquecer os conjuntos de dados poderão ser gerados, obedecendo a ordem, de acordo com a tabela _Dicionários_. No entanto, uma versão gerada desses dicionários já fazem parte do projeto e podem ser encontradas na pasta _dict/_.

---

## Elastic Stack (ELK)

### Elasticsearch

O _Elasticsearch_ é o componente central da stack _ELK_ e é responsável por indexar os dados e fornecer uma API REST para a realização de consultas. 

#### Instalação e execução

1. [Download Elasticsearch](https://www.elastic.co/downloads/elasticsearch)
1. `${ELASTICSEARCH_BASE}/bin/elasticsearch`

#### Mappings

O _Elasticsearch_ é capaz de identificar dinamicamente os tipos de dados enviados para a API e indexação, porém, em alguns casos é necessário informar explicitamente, durante a criação do índice, o tipo de dados do campo. Isso é necessário especialmente para campos do tipo _geopoint_ (nos quais a latitude e longitude são informadas separadas por uma vírgula).

O mapeamento deve ser realizado antes da execução do pipeline do _Logstash_, pois uma ves criado o índice, o mapeamento do tipo de dado do campo não poderá ser alterado. Para realizar o mapeamento siga os seguintes passos:

1. Acesse o [DevTools no Console do Kibana](http://localhost:5601/app/kibana#/dev_tools/console?_g=())
1. Copie o conteúdo do arquivo de mapeamento do conjunto de dados desejado e cole no console
1. Os arquivos são formados por dois comandos: o primeiro irá excluir o índice (caso exista) e o segundo ira criá-lo, já com os mapeamentos de campos necessários

### Logstash

O _Logstash_ é a solução de ETL da _Elastic_, através da qual é possível consumir dados de diversos tipos de fontes diferentes, assim como transformá-los, enriquecê-los e então enviá-los para, também, diversas tipos de destinos diderentes.

Neste projetos os dados serão consumidos de arquivos locais do tipo _CSV_ e enviados para o _Elasticsearch_.

#### Instalação e execução

1. [Logstash Download](https://www.elastic.co/downloads/logstash)
1. `${LOGSTASH_BASE_DIR}/bin/logstash -f arquivo_configuracao_pipeline.conf`

Como o _Logstash_ mantém o canal de entrada aberto esperando receber mais eventos, ele não encerra a execução mesmo após consumir todo o arquivo (ele espera que mais eventos sejam adicionados ao arquivo). Portanto, ele precisará ser interrompido manualmente. Para isso, aguarde até que ele não esteja mais gerando a saída _dots_ (ele irá gerar um "." para cada evento consumido) e utilize CTRL+C para interrompê-lo.

### Kibana

O _Kibana_ é o console de acesso e visualização dos dados indexados no _Elasticsearch_. Através dele é possível realizar consultas nos índices, criars visualizações dos dados e agrupar essas visualizações em dashboards.

#### Instalação e execução

1. [Download Kibana](https://www.elastic.co/downloads/kibana)
1. `${KIBANA_BASE}/bin/kibana`

#### Index Patterns

Os _Index Patterns_ devem ser configurados no _Kibana_ para definir quais índices comporão uma fonte de dados para a construção de visualizações e dashboards. Para configurar um _Index Pattern_ siga os seguintes passos:

1. Acesse o menu [Management do Kibana](http://localhost:5601/app/kibana#/management?_g=())
1. Vá em _Indexes Patterns_
1. _Create Index Pattern_
1. Informe o padrão de índices do conjunto de dados desejado (listados a seguir)
1. Informe o campo _@timestamp_ para ser utilizado como marcador da data do evento

#### Visualizations

As Visualizations possibilitam a visualização dos dados indexados através de componentes visuais como histogramas, gráficos de diversos tipos, mapas, _heatmaps_, nuvens de tags, _gauges_ e outros.

#### Dashboards

Dashboards reunem Visualizations possibilitando a criação de painéis de informação.

---

### Dicionários

| Ordem | Nome | Pipeline | Dicionário gerado|
| --- | --- | --- | --- |
| 1 | Municípios | _pipeline/auxiliares/dict/municipios.conf_ | _dict/auxiliares/municipios.yml_ | 
| 2 | TCE-RS: Municípios | _pipeline/tcers/dict/municipios.conf_ | _dict/tcers/municipios.yml_ |
| 3 | TCE-RS: Funções contábeis | _pipeline/tcers/dict/funcoes.conf_ | _dict/tcers/funcoes.yml_ |
| 4 | TCE-RS: Subfunções contábeis | _pipeline/tcers/dict/subfuncoes.conf_ | _dict/tcers/subfuncoes.yml_ |
| 5 | TCE-RS: Órgãos auditados | _pipeline/tcers/dict/orgaos_auditados.conf_ | _dict/tcers/orgaos-auditados.yml_ |

### Painéis

| Painel | Mappings | Índices | Index Patterns | Visualizations | Dashboards |
| --- | --- | --- | --- | --- | --- |
| TCE-RS / Contábil | _mappings/tcers/balancete-despesa.mapping_, _mappings/tcers/balancete-receita.mapping_ | tcers-balancete-despesa, tcers-balancete-receita | tcers-balancete-despesa,tcers-balancete-receita | contabil.visualizations | contabil.dashboard |
| TCE-RS / LAI |  | tcers-lai | tcers-lai | lai.visualizations | lai.dashboard |
| TCE-RS / Diárias pagas | _mappings/tcers/diarias-pagas.mapping_ | tcers-diarias-pagas | tcers-diarias-pagas | diarias-pagas.visualizations | diarias-pagas.dashboard |
| TCE-RS / Decisões |  | tcers-decisoes | tcers-decisoes | decisoes.visualizations | decisoes.dashboard |


### Fontes de dados abertos

- [Portal de Dados Abertos do TCE-RS](https://dados.tce.rs.gov.br)
- [#Datapoa - Portal de Dados Abertos da Prefeitura de Porto Alegre](http://www.datapoa.com.br/)

| Fonte | Conjunto de dados | Path | Download |
| --- | --- | --- | --- |
| TCE-RS | Dados auxiliares: Funções | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/funcoes.csv](http://dados.tce.rs.gov.br/dados/auxiliar/funcoes.csv) |
| TCE-RS | Dados auxiliares: Sub-funções  | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/subfuncoes.csv](http://dados.tce.rs.gov.br/dados/auxiliar/subfuncoes.csv) |
| TCE-RS | Dados auxiliares: Tipos de unidades | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/tipos_unidades.csv](http://dados.tce.rs.gov.br/dados/auxiliar/tipos_unidades.csv) |
| TCE-RS | Dados auxiliares: Elementos de despesa | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/elementos_de_despesa.csv](http://dados.tce.rs.gov.br/dados/auxiliar/elementos_de_despesa.csv) |
| TCE-RS | Dados auxiliares: Modalidades de aplicação | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/modalidade_de_aplicacao.csv](http://dados.tce.rs.gov.br/dados/auxiliar/modalidade_de_aplicacao.csv) |
| TCE-RS | Dados auxiliares: Órgãos auditados | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv](http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv) |
| TCE-RS | Dados auxiliares: Municípios | _data/tcers/auxiliares/_ | [http://dados.tce.rs.gov.br/dados/auxiliar/municipios.csv](http://dados.tce.rs.gov.br/dados/auxiliar/municipios.csv) |
| TCE-RS | Balancete de despesa | _data/tcers/balancete-despesa/_ | [http://dados.tce.rs.gov.br/dados/municipal/balancete-despesa/](http://dados.tce.rs.gov.br/dados/municipal/balancete-despesa/) |
| TCE-RS | Balancete de receita | _data/tcers/balancete-receita/_ | [http://dados.tce.rs.gov.br/dados/municipal/balancete-receita/](http://dados.tce.rs.gov.br/dados/municipal/balancete-receita/) |
| TCE-RS | Solicitações de informação | _data/tcers/solicitacoes-informacao/_ | [http://dados.tce.rs.gov.br/dados/lai/solicitacoes-de-informacao/](http://dados.tce.rs.gov.br/dados/lai/solicitacoes-de-informacao/) |
| TCE-RS | Diárias pagas | _data/tcers/diarias-pagas/_ | [http://dados.tce.rs.gov.br/dados/institucional/diarias-pagas/](http://dados.tce.rs.gov.br/dados/institucional/diarias-pagas/) |
| TCE-RS | Decisões | _data/tcers/decisoes/_ | [http://dados.tce.rs.gov.br/dados/decisoes/](http://dados.tce.rs.gov.br/dados/decisoes/) |

# Links úteis

- [https://github.com/logstash-plugins//logstash-patterns-core/blob/master/patterns/grok-patterns](Grok patterns)
