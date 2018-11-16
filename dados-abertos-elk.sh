#!/bin/bash

CURL=$(which curl)
LOGSTASH=$(which logstash)
ELASTICSEARCH_HOST="localhost:9200"
KIBANA_HOST="localhost:5601"

# Cores
NC="$(tput sgr0)"
OK="$(tput setaf 2)OK${NC}"
NOK="$(tput setaf 1)NOK${NC}"
PADDING=55

use() {

	echo "${0} [-m] [-p] [-d] "
	echo "	-m		mappings dos índices do Elasticsearch"
	echo "	-p		pipelines do Logstash"
	echo "	-u		dashboards do Kibana"

	exit -1
}

install_elasticsearch_mappings() {
	echo "[Instalando mappings do Elasticsearch]"

	DIR="elasticsearch/mappings/"
	DIR_REPLACE="elasticsearch\/mappings\/"
	FILE_EXTENSION="mapping"
	FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			INDEX_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
		
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

	DIR="logstash/pipelines/"
	DIR_REPLACE="logstash\/pipelines\/"
	FILE_EXTENSION="conf"
	#FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"
	FILES="$(find ${DIR} -name diarias-pagas.${FILE_EXTENSION} -type f 2> /dev/null | grep -v '/dict/' | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			
			PIPELINE_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
			
			printf "Executando pipeline %-${PADDING}s" "${PIPELINE_NAME}..."

			echo "${LOGSTASH} -f ${f} 2&>1 > /dev/null"
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

	DIR="kibana/dashboards/"
	DIR_REPLACE="kibana\/dashboards\/"
	FILE_EXTENSION="dashboard"
	FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			
			DASHBOARD_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
			
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

while getopts "mpd" option
do
	case "${option}" in
		m)
			install_elasticsearch_mappings
			;;
		p)
			run_logstash_pipelines
			;;
		d)
			install_kibana_dashboards
			;;
		*)
			use
			exit -1
			;;
	esac	
done
