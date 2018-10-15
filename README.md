
# Downloads

## TCE-RS

- http://dados.tce.rs.gov.br/dados/auxiliar/funcoes.csv
- http://dados.tce.rs.gov.br/dados/auxiliar/subfuncoes.csv
- http://dados.tce.rs.gov.br/dados/auxiliar/tipos_unidades.csv
- http://dados.tce.rs.gov.br/dados/auxiliar/elementos_de_despesa.csv
- http://dados.tce.rs.gov.br/dados/auxiliar/modalidade_de_aplicacao.csv
- http://dados.tce.rs.gov.br/dados/auxiliar/orgaos_auditados_rs.csv
- http://dados.tce.rs.gov.br/dados/auxiliar/municipios.csv

- http://dados.tce.rs.gov.br/dados/municipal/balancete-despesa/[2004-2017].csv
- http://dados.tce.rs.gov.br/dados/municipal/balancete-receita/[2004-2017].csv
- http://dados.tce.rs.gov.br/dados/lai/solicitacoes-de-informacao/[2012-2017].csv

# Elasticsearsh

## Mappings

# Logstash

## Ordem
- auxiliares/dict/municipios.conf
- pipeline/tcers/dict/municipios.conf
- pipeline/tcers/dict/funcoes.conf

# Kibana 

## Index Patterns

- tcers-balancete-despesa,tcers-balancete-receita
- tcers-lai

## Visualizations

- contabil.visualization
- lai.visualization

## Dashboards

- contabil.dashboard
- lai.dashboard
