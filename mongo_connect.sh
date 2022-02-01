#!/usr/local/usr/local/bin/bash

# --------------------------------------------------------------------------------------------
# [Hicham Taha] mongo_connect.sh
#				Connect to a mongo cluster node.
# --------------------------------------------------------------------------------------------

script_dir=$( dirname "${BASH_SOURCE[0]}" )
source ${script_dir}/variables/mongo_variables.sh

mongo_connect_usage() {
	echo "Usage: ${0} PROJECT DATABASE

Connect to a mongo database.

PROJECT			Project key used as a reference when mapping varibales/mongo_variables.sh.
DATABASE		Either dev or prod." >&2
	exit 1
}

if [[ ${#} -ne 2 ]]; then
	mongo_connect_usage
fi

# Validate project argument.
if [[ -z ${1} ]] || [[ ! -v "hosts[${1}]" ]]; then
	mongo_connect_usage
fi

if [[ -z ${2} ]] || [[ ! -v "databases[${2}]" ]]; then
	mongo_connect_usage
fi

echo "Connecting to mongo project ${1} on database ${2}."
mongo "${mongoConnectionStrings[$1]}/${2}" --username ${usernames[$1]} --password ${passwords[$1]} --quiet