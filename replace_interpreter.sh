#!/bin/bash

# --------------------------------------------------------------------------------------------
# [Hicham Taha] replace_interpreter.sh
#				Replace all relevent shell script interpreters in this project.
# --------------------------------------------------------------------------------------------

replace_interpreter_usage() {
	echo "Usage: ${0} OLD_INTERPRETER NEW_INTERPRETER

Replace all relevent shell script interpreters in this project." >&2
	exit 1
}

if [[ -z ${1} ]]; then
	replace_interpreter_usage
fi

if [[ -z ${2} ]]; then
	replace_interpreter_usage
fi

OLD_INTERPRETER=${1}
NEW_INTERPRETER=${2}

# Mac OS approach.
sed -i '' "s/${OLD_INTERPRETER}/${NEW_INTERPRETER}/g" mongo_connect.sh
sed -i '' "s/${OLD_INTERPRETER}/${NEW_INTERPRETER}/g" mongo_migrate_export.sh
sed -i '' "s/${OLD_INTERPRETER}/${NEW_INTERPRETER}/g" mongo_migrate_import.sh
sed -i '' "s/${OLD_INTERPRETER}/${NEW_INTERPRETER}/g" mongo_migrate.sh
sed -i '' "s/${OLD_INTERPRETER}/${NEW_INTERPRETER}/g" variables/mongo_variables.sh

# When scripts are placed in linux node container, maybe use this approach. ( be careful to not unintentially modify wrong file ).
# find ./scripts -type f -exec sed -i "s/test_node/breast_node/g" {} \;
# find . -maxdepth 1 -type f -exec sed -i "s/test_node/breast_node/g" {} \;
