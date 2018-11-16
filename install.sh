#!/bin/bash

CURL=$(which curl)
ELASTICSEARCH_HOST="localhost:9200"
KIBANA_HOST="localhost:5601"

NC="$(tput sgr0)"
OK="$(tput setaf 2)OK${NC}"
NOK="$(tput setaf 1)NOK${NC}"
PADDING=55

ACTION=""

use() {

	echo "${0} -i|-u "
	echo "	-i		instalação"
	echo "	-u		desinstalação"

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
			
			REQUEST_RETURN_CODE="$(${CURL} -o /dev/null -i --silent -w '%{http_code}' -X PUT -H "Content-Type: application/json" http://${ELASTICSEARCH_HOST}/${INDEX_NAME} -d @${f})"
			
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

	echo ""
}

install_kibana_index_patterns() {
	echo "[Instalando index patterns do Kibana]"

	DIR="kibana/index-patterns/"
	DIR_REPLACE="kibana\/index-patterns\/"
	FILE_EXTENSION="index-pattern"
	FILES="$(find ${DIR} -name \*.${FILE_EXTENSION} -type f 2> /dev/null | sort)"

	if [ ! -z "${FILES}" ]
	then
		for f in ${FILES}
		do
echo "$f"			
			INDEX_PATTERN_NAME="$(echo ${f} | cut -d'/' -f3- | sed 's/\//-/g' | sed 's/.'${FILE_EXTENSION}'//g')"
echo "$INDEX_PATTERN_NAME"		
			printf "Instalando index pattern %-${PADDING}s" "${INDEX_PATTERN_NAME}..."
			
			REQUEST_RETURN_CODE="$(${CURL} -o /dev/null -i --silent -w '%{http_code}' -X POST -H "Content-Type: application/json" http://${KIBANA_HOST}/api/saved_objects/index-pattern/${INDEX_PATTERN_NAME} -d @${f})"
echo "$REQUEST_RETURN_CODE"			
			if [ "${REQUEST_RETURN_CODE}" != "200" ]
			then
				printf "${NOK}\n"
			else
				printf "${OK}\n"
			fi
		done
	else
		echo "Não foram encontrados arquivos de index pattern"
	fi
	echo ""
}

uninstall_elasticsearch_indice() {
	echo "[Desinstalando mappings do Elasticsearch]"

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
			
			REQUEST_RETURN_CODE="$(${CURL} -o /dev/null -i --silent -w '%{http_code}' -X DELETE http://${ELASTICSEARCH_HOST}/${INDICE_NAME})"
	
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
			#install_elasticsearch_mappings
			install_kibana_index_patterns
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
