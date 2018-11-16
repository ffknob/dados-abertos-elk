#!/bin/bash

LOGFILE="dados-abertos-elk.log"

CURL=$(which curl)
ELASTICSEARCH_HOST="localhost:9200"
KIBANA_HOST="localhost:5601"

# Cores
NC="$(tput sgr0)"
OK="$(tput setaf 2)OK${NC}"
NOK="$(tput setaf 1)NOK${NC}"
PADDING=55

use() {

	echo "${0} -i|-u "
	echo "	-i		instalação"
	echo "	-u		desinstalação"

	exit -1
}

install_elasticsearch_mappings() {
	echo "[Instalando mappings do Elasticsearch]" | tee -a ${LOGFILE}

	DIR="elasticsearch/mappings/"
	DIR_REPLACE="elasticsearch\/mappings\/"
	FILE_EXTENSION="mapping"
	#FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"
	FILES="$(find ${DIR} -name diarias-pagas.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			INDEX_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
		
			printf "Instalando mapping do índice %-${PADDING}s" "${INDEX_NAME}..."
			echo "Instalando mapping do índice ${INDEX_NAME}..." >> ${LOGFILE}

			REQUEST_RETURN_CODE="$(${CURL} -o - -i --silent -w '%{http_code}' -XPUT -H "Content-Type: application/json" http://${ELASTICSEARCH_HOST}/${INDEX_NAME} -d @${f} 2&>1 >> ${LOGFILE})"
			echo "" >> ${LOGFILE}

			if [ "${REQUEST_RETURN_CODE}" != "200" ]
			then
				printf "${NOK}\n"
				echo "[ERRO]: Na instalação do índice ${INDEX_NAME}" >> ${LOGFILE}
			else
				printf "${OK}\n"
				echo "[SUCESSO]: Na instalação do índice ${INDEX_NAME}" >> ${LOGFILE}
			fi
		done
	else
		echo "Não foram encontrados arquivos de mapping" | tee -a ${LOGFILE}
	fi

	echo ""
}

run_logstash_pipelines() {
	echo "[Executando pipelines do Logstash]" | tee -a ${LOGFILE}

	DIR="logstash/pipelines/"
	DIR_REPLACE="logstash\/pipelines\/"
	FILE_EXTENSION="conf"
	#FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"
	FILES="$(find ${DIR} -name diarias-pagas.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			
			PIPELINE_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
			
			printf "Executando pipeline %-${PADDING}s" "${PIPELINE_NAME}..."
			echo "Executando pipeline ${PIPELINE_NAME}..." >> ${LOGFILE}

			echo "${LOGSTASH} -f ${f} 2&>1 >> ${LOGFILE}"
	
			if [ $? -ne 0 ]
			then
				printf "${NOK}\n"
				echo "[ERRO]: Na execução do pipeline ${PIPELINE_NAME}" >> ${LOGFILE}
			else
				printf "${OK}\n"
				echo "[SUCESSO]: Na execução do pipeline ${PIPELINE_NAME}" >> ${LOGFILE}
			fi
		done
	else
		echo "Não foram encontrados arquivos de pipeline"
	fi
			
	echo ""
}

install_kibana_dashboards() {
	echo "[Instalando dashboards do Kibana]" | tee -a ${LOGFILE}

	DIR="kibana/dashboards/"
	DIR_REPLACE="kibana\/dashboards\/"
	FILE_EXTENSION="dashboard"
	#FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"
	FILES="$(find ${DIR} -name diarias-pagas.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			
			DASHBOARD_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
			
			printf "Instalando dashboard %-${PADDING}s" "${DASHBOARD_NAME}..."
			echo "Instalando dashboard ${DASHBOARD_NAME}" >> ${LOFGILE}

			REQUEST_RETURN_CODE="$(${CURL} -o ${LOGFILE} -i --silent -w '%{http_code}' -XPOST -H "Content-Type: application/json" -H "kbn-xsrf: true" http://${KIBANA_HOST}/api/kibana/dashboards/import -d @${f} 2&>1 >> ${LOGFILE})"
			echo "" >> ${LOGFILE}
			
			if [ "${REQUEST_RETURN_CODE}" != "200" ]
			then
				printf "${NOK}\n"
				echo "[ERRO]: Na instalação do dashboard ${DASHBOARD_NAME}" >> ${LOGFILE}
			else
				printf "${OK}\n"
				echo "[SUCESSO]: Na instalação do dashboard ${DASHBOARD_NAME}" >> ${LOGFILE}
			fi
		done
	else
		echo "Não foram encontrados arquivos de dashboard"
	fi

	echo ""
}

uninstall_elasticsearch_indice() {
	echo "[Desinstalando mappings do Elasticsearch]" | tee ${LOGFILE}

	DIR="elasticsearch/mappings/"
	DIR_REPLACE="elasticsearch\/mappings\/"
	FILE_EXTENSION="mapping"
	FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
			INDICE_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
		
			printf "Desinstalando índice %-${PADDING}s" "${INDICE_NAME}..."
			echo "Desinstalando índice ${INDICE_NAME}" >> ${LOGFILE}
			
			REQUEST_RETURN_CODE="$(${CURL} -o ${LOGFILE} -i --silent -w '%{http_code}' -X DELETE http://${ELASTICSEARCH_HOST}/${INDICE_NAME})"
	
			if [ "${REQUEST_RETURN_CODE}" != "200" ]
			then
				printf "${NOK}\n"
			else
				printf "${OK}\n"
			fi
		done
	else
		echo "Não foram encontrados arquivos de mapping"
	fi
}

if [ $# -eq 0 ]
then
	use
fi

while getopts "iu" option
do
	case "${option}" in
		i)
			install_elasticsearch_mappings
			#run_logstash_pipelines
			#install_kibana_dashboards
			;;
		u)
			uninstall_elasticsearch_mappings
			;;
		*)
			echo "Opção inválida."
			use
			exit -1
			;;
	esac	
done
