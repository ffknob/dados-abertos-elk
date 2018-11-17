#!/bin/bash

CURL=$(which curl)
LOGSTASH=$(which logstash)
ELASTICSEARCH_HOST="localhost:9200"
KIBANA_HOST="localhost:5601"

# Diretórios
MAPPINGS_DIR="elasticsearch/mappings/"
MAPPING_FILE_EXTENSION="mapping"
PIPELINES_DIR="logstash/pipelines/"
PIPELINE_FILE_EXTENSION="conf"
DASHBOARDS_DIR="kibana/dashboards/"
DASHBOARD_FILE_EXTENSION="dashboard"

# Cores
NC="$(tput sgr0)"
OK="$(tput setaf 2)OK${NC}"
NOK="$(tput setaf 1)NOK${NC}"
PADDING=55

use() {

	echo "${0} -e [indice] | -l [pipeline] | -k [dashboard] "
	echo "	-e		cria os índices no Elasticsearch com os devidos mappings"
	echo "	-l		executa pipelines do Logstash"
	echo "	-k		instala dashboards do Kibana"

	echo

	echo "[Elasticsearch] Índices disponíveis:"
	find ${MAPPINGS_DIR} -name \*.${MAPPING_FILE_EXTENSION} -type f 2> /dev/null | sort | sed 's/^/\t- /' 2> /dev/null
	echo

	echo "[Logstash] Pipelines disponíveis:"
	find ${PIPELINES_DIR} -name \*.${PIPELINE_FILE_EXTENSION} -type f 2> /dev/null | sort | sed 's/^/\t- /' 2> /dev/null
	echo

	echo "[Kibana] Dashboards disponíveis:"
	find ${DASHBOARDS_DIR} -name \*.${DASHBOARD_FILE_EXTENSION} -type f 2> /dev/null | sort | sed 's/^/\t- /' 2> /dev/null
	echo

	echo

	exit -1
}

install_elasticsearch_mappings() {
	echo "[Instalando mappings do Elasticsearch]"

	if [ -z "${1}" ]
	then
		FILES="$(find ${MAPPINGS_DIR} -name \*.${MAPPING_FILE_EXTENSION} -type f 2> /dev/null | sort)"
	else
		FILES="${1}"
	fi

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			INDEX_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${MAPPING_FILE_EXTENSION}'//g')"
		
			printf "Instalando mapping do índice %-${PADDING}s" "${INDEX_NAME}..."

			REQUEST_RETURN_CODE="$(${CURL} -o /dev/null -i --silent -w '%{http_code}' -XPUT -H "Content-Type: application/json" http://${ELASTICSEARCH_HOST}/${INDEX_NAME} -d @${f})"

			if [ "${REQUEST_RETURN_CODE}" != "200" ]
			then
				printf "${NOK}\n"
				RETURN=-1
			else
				printf "${OK}\n"
				RETURN=0
			fi
		done
	else
		echo "Não foram encontrados arquivos de mapping"
	fi

	echo ""
	return ${RETURN}
}

run_logstash_pipelines() {
	echo "[Executando pipelines do Logstash]"
	echo "IMPORTANTE: Tenha certeza de que os dicionários necessários já foram gerados e se encontram em dict/. "

	if [ -z "${1}" ]
	then
		FILES="$(find ${PIPELINES_DIR} -name \*.${PIPELINE_FILE_EXTENSION} -type f 2> /dev/null | grep -v '/dict/' | sort)"
	else
		FILES="${1}"
	fi

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			
			PIPELINE_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${PIPELINE_FILE_EXTENSION}'//g')"
			
			printf "Executando pipeline %-${PADDING}s" "${PIPELINE_NAME}..."

			echo "${LOGSTASH} -f ${f} 2>&1 > /dev/null"
			${LOGSTASH} -f ${f} 2>&1 > /dev/null
	
			if [ $? -ne 0 ]
			then
				printf "${NOK}\n"
				RETURN=-1
			else
				printf "${OK}\n"
				RETURN=0
			fi
		done
	else
		echo "Não foram encontrados arquivos de pipeline"
	fi
			
	echo ""
	return ${RETURN}
}

install_kibana_dashboards() {
	echo "[Instalando dashboards do Kibana]"

	if [ -z "${1}" ]
	then
		FILES="$(find ${DASHBOARDS_DIR} -name \*.${DASHBOARD_FILE_EXTENSION} -type f 2> /dev/null | sort)"
	else
		FILES="${1}"
	fi

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			
			DASHBOARD_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${DASHBOARD_FILE_EXTENSION}'//g')"
			
			printf "Instalando dashboard %-${PADDING}s" "${DASHBOARD_NAME}..."

			REQUEST_RETURN_CODE="$(${CURL} -o /dev/null -i --silent -w '%{http_code}' -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: true" http://${KIBANA_HOST}/api/kibana/dashboards/import -d @${f})"
			
			if [ "${REQUEST_RETURN_CODE}" != "200" ]
			then
				printf "${NOK}\n"
				RETURN=-1
			else
				printf "${OK}\n"
				RETURN=0
			fi
		done
	else
		echo "Não foram encontrados arquivos de dashboard"
	fi

	echo ""
	return ${RETURN}
}

if [ $# -eq 0 ]
then
	use
fi

while getopts "elk" option
do
	case "${option}" in
		e)
			install_elasticsearch_mappings ${2}
			;;
		l)
			#run_logstash_pipelines ${2}
			;;
		k)
			#install_kibana_dashboards ${2}
			;;
		*)
			use
			exit -1
			;;
	esac	
done
