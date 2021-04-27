#!/bin/bash

# Might need these to use the mongo shell if not using docker approach.
# brew services stop mongodb
# brew uninstall mongodb
# brew tap mongodb/brew
# brew install mongodb-community
# brew install mongodb/brew/mongodb-community-shell.
# brew services start mongodb-community

script_dir=$( dirname "${BASH_SOURCE[0]}" )
source ${script_dir}/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script. Colon means it expects a value, no colon is just a flag.
mongo_migrate_import_usage() {
	echo "Usage ${0} [a:p:f:d:c:tvy]

Import full collection(s) from one project's exported database(s) to another.

[-p project to]         Specify which project this migration import is to.
[-a project from]       Specify which project this migration import is from. Defaults to value of -p.
[-d database to]        Specify which database to import into ( dev or prod ).
[-f database from]      Specify which collection environment to import from. Defaults to value of -d.
[-c collections]        Specify comma delimited collections to migrate. Specify 'all' to import all collections.
[-t truncate]           Whether to empty collection(s) before importing ( optional ).
[-v verbose]            Enable verbosity for script.
[-y skip_confirmation]  Skip detail confirmation prompt." >&2
    exit 1
}

# Helper method that takes project name as $1, database as $2, collection as $3, collections_dir as $4, truncate option as $5.
mongo_import() {
     mongoimport \
    --host ${hosts[$1]} \
    --username ${usernames[$1]} \
    --password ${passwords[$1]} \
    --authenticationDatabase ${authentication_databases[$1]} \
    --db $2 \
    --collection $3 \
    --type json \
    --file "${4}/${3}.json" \
    ${5} ${isMongoSSL[$1]}
}

mi_project_from=''
mi_project_to=''
mi_database_from=''
mi_database_to=''
mi_collections=''
mi_truncate=''
mi_verbose='false'
mi_skip_confirmation='false'

OPTIND=1 # Reset for this script if using mongo_migrate.sh
while getopts a:p:f:d:c:tvy OPTION
do
    case ${OPTION} in
        a) mi_project_from="${OPTARG}";;
        p) mi_project_to="${OPTARG}";;
        f) mi_database_from="${OPTARG}";;
        d) mi_database_to="${OPTARG}";;
        c) mi_collections="${OPTARG}";;
        t) mi_truncate='--drop';;
        v) mi_verbose='true';;
        y) mi_skip_confirmation='true';;

        # Handle unknown cases here.
        *) mongo_migrate_import_usage ;;
    esac
done
# Map project names to mongo key.
if [[ -v "projects_mapped[${mi_project_from}]" ]]; then mi_project_from=${projects_mapped[$mi_project_from]}; fi
if [[ -v "projects_mapped[${mi_project_to}]" ]]; then mi_project_to=${projects_mapped[$mi_project_to]}; fi

# Check project to value.
if [[ -z $mi_project_to ]] || [[ ! -v "hosts[${mi_project_to}]" ]]; then echo "Invalid -p option: ${mi_project_to}."; mongo_migrate_import_usage; fi

# Default project from to the same as project to.
if [[ -z $mi_project_from ]]; then mi_project_from=$mi_project_to; fi

# Ensure project from is a legitimate value.
if [[ ! -v "hosts[${mi_project_from}]" ]]; then echo "Invalid -a option: ${mi_project_from}."; mongo_migrate_import_usage; fi

# Check database value.
if [[ -z $mi_database_to ]] || [[ ! -v "databases[${mi_database_to}]" ]]; then echo "Invalid -d option: ${mi_database_to}."; mongo_migrate_import_usage; fi
if [[ ${mi_database_to} = 'prod' ]]; then echo "You are not allowed to import into production databases." >&2; exit 1; fi

# Default from database to same as database importing.
if [[ -z $mi_database_from ]]; then mi_database_from=$mi_database_to; fi

# Check from value ( if passed in )
if [[ ! -z $mi_database_from ]] && [[ ! -v "databases[${mi_database_from}]" ]]; then echo "Invalid -f option: ${mi_database_from}."; mongo_migrate_import_usage; fi 

# Check collections value.
collections_dir=${script_dir}/collections/${mi_project_from}/${mi_database_from}
if [[ -z $mi_collections ]]; then
    mongo_migrate_import_usage
elif [[ $mi_collections = 'all' ]]; then

    # Grab all collections from appropriate collection directory.
    collections_array=()
    for file in $collections_dir/*; do
        collections_array+=($( basename $file | cut -f 1 -d '.' ))
    done
    
else
    # Convert comma delimited collection string into list.
    IFS=',' read -r -a collections_array <<< $mi_collections
fi

# Import json files into $database.
echo "Import Details
Project From: ${mi_project_from}
Project To: ${mi_project_to}
Collections: ${collections_array[@]}
Database From: ${mi_database_from}
Database To: ${mi_database_to}
Truncate: ${mi_truncate}
Directory: ${collections_dir}
"

# Prompt a confirmation on the details ( if not skipped ).
if [[ $mi_skip_confirmation = 'false' ]]; then
    read -p 'Are these details correct?: (y/n)' confirmation
    if [[ ! $confirmation = 'y' ]]; then
        echo "Exiting script." >&2
        exit 1
    fi
fi

echo "" > ${script_dir}/logs/mongo_migrate_import_logs.txt # Empties log.
for collection in "${collections_array[@]}"
do 
    # Import each specified collection.
    if [[ $mi_verbose = 'true' ]]; then
        mongo_import $mi_project_to $mi_database_to $collection $collections_dir $mi_truncate 2>&1 | tee -a ${script_dir}/logs/mongo_migrate_import_logs.txt
    else
        mongo_import $mi_project_to $mi_database_to $collection $collections_dir $mi_truncate &>> ${script_dir}/logs/mongo_migrate_import_logs.txt
    fi

    echo "Imported ${collections_dir}/${collection}.json"
done

echo "Finished importing ${mi_database_to} collections from ${collections_dir}."