# Dados Abertos com Elastic Stack (ELK)

Este projeto tem o objetivo de facilitar a utilização de conjuntos de dados abertos, fazendo uso da _Elastic Stack_ (_Elasticsearch + Logstash + Kibana_), que é uma solução baseada em software livre que permite facilmente consumir fontes de dados, manipular/transformar/enriquecer esses dados, indexá-los e, por fim, visualizá-los em dashboards.

> Neste projeto está sendo utilizada a versão **6.5.0** da _Elastic Stack_.


* [Roteiro (utilizando a ferramenta _dados-abertos-elk.sh_)](#roteiro-utilizando-a-ferramenta-_dados-abertos-elk.sh_)
* [Estrutura de diretórios](#estrutura-de-diretórios)
* [Conjuntos de dados](#conjuntos-de-dados)
* [Dicionários](#dicionários)
* [Elastic Stack (ELK)](#elastic-stack-elk)
  * [Elasticsearch](#Elasticsearch)
  * [Logstash](#logstash)
  * [Kibana](#kibana)
* [Fontes de dados abertos](#fontes-de-dados-abertos)
* [Utilidades](#utilidades)
* [Links úteis](#links-úteis)

## Roteiro utilizando a ferramenta _dados-abertos-elk.sh_

1. Baixar os conjuntos de dados abertos desejados nas [Fontes de Dados Abertos](#fontes-de-dados-abertos)
1. Instalar, executar e testar o _Elasticsearch_, _Kibana_ e _Logstash_

```
$ curl -O https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.5.0.tar.gz
$ tar xfz elasticsearch-6.5.0.tar.gz
$ elasticsearch-6.5.0/bin/elasticsearch
$ curl http://localhost:9200

$ curl -O https://artifacts.elastic.co/downloads/kibana/kibana-6.5.0-linux-x86_64.tar.gz
$ tar xfz kibana-6.5.0.tar.gz
$ kibana-6.5.0/bin/kibana
$ curl http://localhost:5601/

$ curl -O https://artifacts.elastic.co/downloads/logstash/logstash-6.5.0.tar.gz
$ tar xfz logstash-6.5.0.tar.gz
$ logstash-6.5.0/bin/logstash --version
```

3. Clonar este projeto

```
$ git clone https://github.com/ffknob/dados-abertos-elk.git
```

4. Criar os índices no _Elasticsearch_ a partir dos arquivos que se encontram no diretório _elasticsearch/mappings/_

```
dados-abertos-elk/ $ ./dados-abertos-elk.sh -e
```

5. Criar os _Dashboards_ no _Kibana_ a partir dos arquivos que se encontram no diretório _kibana/dashboards/_

```
dados-abertos-elk/ $ ./dados-abertos-elk.sh -k
```
> Esses arquivos foram gerados a partir da API de exportação de _Dshboards_ do _Kibana_ e já incluem o _Index Pattern_, as _Visualizations_ e o _Dashboard_ propriamente dito.

6. _Opcional_: Executar _Pipelines_ para os dicionários no _Logstash_

```
dados-abertos-elk/ $ ./dados-abertos-elk.sh -l logstash/pipelines/tcers/dict/municipios.conf
```
> Já foram executados e se encontram na pasta _dict/_.

> Esses _Pipelines_ geram arquivos YAML que serão utilizados pelos _Pipelines_ principais.

7. Executar _Pipelines_ no _Logstash_

```
dados-abertos-elk/ $ ./dados-abertos-elk.sh -l logstash/pipelines/poa/acidentes-transito.conf
```
> O Logstash ficará em execução aguardando mais eventos nos inputs configurados. Ele deverá ser encerrado manualmente (CTRL+C) assim que o respectivo índice no Elasticsearch não estiver recebendo mais eventos, ou que o indicador do filtro de saída dots {} não estiver mais imprimindo pontos na tela.

8. Acessar o _Kibana_ e ir em _Dashboards_

## Estrutura de diretórios

> Consultar a [estrutura completa de arquivos e diretórios](#estrutura-de-arquivos-e-diretórios-do-projeto)

* _data/_: diretório para armazenar os arquivos _CSV_ dos conjuntos de dados, organizado por fonte de origem, tipo e, quando necesário, formato
* _dict/_: diretório com os dicionários que serão utilziados pelos _Pipelines_ principais
* _elasticsearch/mappings/_: arquivos de _Mapping_ dos índices que serão criados no _Elasticsearch_
* _kibana/dashboards/_: arquivos de configuração dos _Dashboards_ do _Kibana_, organizado por fonte de origem e tipo
* _logstash/pipelines/_: arquivos de configuração dos _Pipelines_ do _Logstash_, organizado por fonte de origem e tipo

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

### Logstash

O _Logstash_ é a solução de ETL da _Elastic_, através da qual é possível consumir dados de diversos tipos de fontes diferentes, assim como transformá-los, enriquecê-los e então enviá-los para, também, diversas tipos de destinos diderentes.

Neste projetos os dados serão consumidos de arquivos locais do tipo _CSV_ e enviados para o _Elasticsearch_.

#### Instalação e execução

1. [Download Logstash](https://www.elastic.co/downloads/logstash)
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
1. Informe o padrão de índices do conjunto de dados desejado
1. Informe o campo _@timestamp_ para ser utilizado como marcador da data do evento

#### Visualizations

As _Visualizations_ possibilitam a visualização dos dados indexados através de componentes visuais como histogramas, gráficos de diversos tipos, mapas, _heatmaps_, nuvens de tags, _gauges_ e outros.

#### Dashboards

_Dashboards_ reunem _Visualizations_ possibilitando a criação de painéis de informação.

---

## Fontes de dados abertos

| Fonte | Conjunto de dados | Path | Download |
| --- | --- | --- | --- |
| POA | Acidentes de Trânsito | _data/poa/acidentes-transito/_ | [http://http://www.datapoa.com.br/dataset/acidentes-de-transito/](http://http://www.datapoa.com.br/dataset/acidentes-de-transito/) |
| | | | |
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

## Utilidades

### Ferramenta _dados-abertos-elk.sh_

Ferramenta utilitária criada para facilitar a utilização deste projeto. Através dela é possível:

1. **[TODO]** Realizar o download dos conjuntos de dados abertos
1. Criar os índices no _Elasticsearch_, já com o _mapping_ necessário
1. Criar os _dashboards_ no _Kibana_
1. Executar _pipelines_ do _Logstash_

```
dados-abertos-elk/ $ ./dados-abertos-elk.sh -e [indice] | -l <pipeline> | -k [dashboard]
	-e		cria os índices no Elasticsearch com os devidos mappings
	-l		executa pipeline do Logstash
	-k		instala dashboards do Kibana
```

### API _Elasticsearch_

- Verificar índices existentes
```
$ curl -XGET http://localhost:9200/_cat/indices?pretty
```

- Verificar _mapping_ de um índices
```
$ curl -XGET http://localhost:9200/poa-acidentes-transito/_mappings?pretty
```

- Criar um índice
```
$ curl -XPUT -H "Content-Type: application/json" http://localhost:9200/poa-acidentes-transito -d@elasticsearch/mappings/poa/acidentes-transito.mapping
```

- Excluir um índice
```
$ curl -XDELETE http://localhost:9200/poa-acidentes-transito/
```

- Pesquisar em um índice
```
$ curl -XGET http://localhost:9200/poa-acidentes-transito/_search?pretty
$ curl -XGET http://localhost:9200/poa-acidentes-transito/_search\?q\=CAVALHADA\&pretty
```
>  Para uma pesquisa específica deverá ser enviado no _body_ uma _query_ no padrão [_Query DSL_](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html) do _Elasticsearch_ (consultar documentação).


### API _Kibana_

- Criar _Index Pattern_ no Kibana:
```
$ curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: true" http://localhost:5601/api/saved_objects/index-pattern/poa-acidentes-transito -d'{"attributes":{"title": "poa-acidentes-transito","timeFieldName": "@timestamp"}}'
```

- Exportar _Dashboard_ do Kibana (_Index Pattern_ + _Visualizations_ + _Dashboard_):
```
$ curl -k -XGET http://localhost:5601/api/kibana/dashboards/export\?dashboard\=ce92e510-ea65-11e8-8fb3-31b5d3f2749f > acidentes-transito.dashboard
```
> O identificador do _Dashboard_ pode ser obtido na _query_string_ da URL ao entrar no _Dashboard_ através do console do _Kibana_.

- Importar _Dashboard_ no Kibana:
```
$ curl -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: true" http://localhost:5601/api/kibana/dashboards/import -d @acidentes-transito.dashboard
```
## Estrutura de arquivos e diretórios do projeto
```
.
├── data/
│   ├── auxiliares/
│   │   └── municipios.csv
│   ├── poa/
│   │   └── acidentes-transito/
│   │       ├── f1/
│   │       │   ├── acidentes-2010.csv
│   │       │   ├── acidentes-2011.csv
│   │       │   └── acidentes-2012.csv
│   │       ├── f2/
│   │       │   └── acidentes-2013.csv
│   │       ├── f3/
│   │       │   └── acidentes-2014.csv
│   │       ├── f4/
│   │       │   └── acidentes-2015.csv
│   │       └── f5/
│   │           └── acidentes-2016.csv
│   └── tcers/
│       ├── auxiliares/
│       │   ├── elementos_de_despesa.csv
│       │   ├── funcoes.csv
│       │   ├── grupos_natureza.csv
│       │   ├── limites_gastos.csv
│       │   ├── municipios.csv
│       │   ├── orgaos_auditados_rs.csv
│       │   ├── subfuncoes.csv
│       │   └── tipos_unidades.csv
│       ├── balancete-despesa/
│       │   └── 2017.csv
│       ├── balancete-receita/
│       │   └── 2017.csv
│       ├── decisoes/
│       │   ├── 2011.csv
│       │   ├── 2012.csv
│       │   ├── 2013.csv
│       │   ├── 2014.csv
│       │   ├── 2015.csv
│       │   ├── 2016.csv
│       │   └── 2017.csv
│       ├── diarias-pagas/
│       │   ├── 2008.csv
│       │   ├── 2009.csv
│       │   ├── 2010.csv
│       │   ├── 2011.csv
│       │   ├── 2012.csv
│       │   ├── 2013.csv
│       │   ├── 2014.csv
│       │   ├── 2015.csv
│       │   ├── 2016.csv
│       │   └── 2017.csv
│       └── lai/
│           ├── 2012.csv
│           ├── 2013.csv
│           ├── 2014.csv
│           ├── 2015.csv
│           ├── 2016.csv
│           └── 2017.csv
├── dict/
│   ├── auxiliares/
│   │   └── municipios.yml
│   └── tcers/
│       ├── funcoes.yml
│       ├── municipios.yml
│       ├── orgaos-auditados.yml
│       └── subfuncoes.yml
├── elasticsearch/
│   └── mappings/
│       ├── poa/
│       │   └── acidentes-transito.mapping
│       └── tcers/
│           ├── balancete-despesa.mapping
│           ├── balancete-receita.mapping
│           ├── decisoes.mapping
│           ├── diarias-pagas.mapping
│           └── lai.mapping
├── kibana/
│   └── dashboards/
│       ├── poa/
│       │   └── acidentes-transito.dashboard
│       └── tcers/
│           ├── contabil.dashboard
│           ├── diarias-pagas.dashboard
│           └── lai.dashboard
├── logstash/
│   └── pipelines/
│       ├── auxiliares/
│       │   └── dict/
│       │       └── municipios.conf
│       ├── poa/
│       │   └── acidentes-transito.conf
│       └── tcers/
│           ├── dict/
│           │   ├── funcoes.conf
│           │   ├── municipios.conf
│           │   ├── orgaos-auditados.conf
│           │   └── subfuncoes.conf
│           ├── balancete-despesa.conf
│           ├── balancete-receita.conf
│           ├── decisoes.conf
│           ├── diarias-pagas.conf
│           └── lai.conf
├── dados-abertos-elk.sh*
└── README.md
```

## Links úteis

### Portais de dados abertos

- [Portal de Dados Abertos do TCE-RS](https://dados.tce.rs.gov.br)
- [Portal de Dados Abertos do Governo do Estado do RS](https://dados.rs.gov.br)
- [#Datapoa - Portal de Dados Abertos da Prefeitura de Porto Alegre](http://www.datapoa.com.br/)

### Elastic Stack

- [Telegram: Elastic Fantastics Brasil](https://web.telegram.org/#/im?p=@ElasticFantasticsBR)
- [Elastic Forums](https://discuss.elastic.com)
- [Query DSL](https://www.elastic.co/guide/en/elasticsearch/reference/current/query-dsl.html)
- [Grok patterns](https://github.com/logstash-plugins/logstash-patterns-core/blob/master/patterns/grok-patterns)
