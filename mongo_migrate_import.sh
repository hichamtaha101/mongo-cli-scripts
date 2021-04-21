#!/usr/local/bin/bash

source ~/scripts/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script.
mongo_migrate_import_usage() {
	echo "Usage ${0} [p:d:c:f:tvy]

Import full collections from a your local to a remote location.

[-p project]            Specify which project this migration import is for.
[-d database]           Specify which database to import into ( dev or prod ).
[-c collections]        Specify comma delimited collections to migrate. Specify 'all' to import all collections.
[-f from]               Speicfy which collection environment to import from. Defaults to database.
[-t truncate]           Whether to empty collection(s) before importing ( optional ).
[-v verbose]            Enable verbosity for script.
[-y skip_confirmation]  Skip detail confirmation prompt." >&2
    exit 1
}

# Helper method that takes project name as $1 argument, database as $2 argument, collection as $3 argument, collections_dir as $4 argument.
mongo_import() {
     mongoimport \
    --host ${hosts[$1]} \
    --username ${usernames[$1]} \
    --password ${passwords[$1]} \
    --authenticationDatabase ${authentication_databases[$1]} \
    --db $2 \
    --collection $3 \
    --ssl \
    --type json \
    --file "${4}/${3}.json"
}

# Helper method that takes project name as the $1 argument and database as the $2 argument.
mongo_truncate() {
    mongo \
    "${mongoConnectionStrings[$1]}/${2}" \
    --username ${usernames[$1]} \
    --password ${passwords[$1]} \
    --quiet \
    --eval "db.${collection}.deleteMany({});"
}

mi_project=''
mi_collections=''
mi_database=''
mi_from=''
mi_truncate='false'
mi_verbose='false'
mi_skip_confirmation='false'

OPTIND=1 # Reset for this script if using mongo_migrate.sh
while getopts p:d:c:f:tvy OPTION
do
    case ${OPTION} in
        p) mi_project="${OPTARG}" ;;
        d) mi_database="${OPTARG}" ;;
        c) mi_collections="${OPTARG}" ;;
        t) mi_truncate='true' ;;
        v) mi_verbose='true' ;;
        f) mi_from="${OPTARG}" ;;
        y) mi_skip_confirmation='true' ;;

        # Handle unknown cases here.
        *) mongo_migrate_import_usage ;;
    esac
done

#Check project value.
if [[ -z $mi_project ]] || [[ ! ${!hosts[@]} =~ $mi_project ]]; then
    mongo_migrate_import_usage
fi

# Check database value.
if [[ -z $mi_database ]] || [[ ! ${databases[@]} =~ $mi_database ]]; then
    mongo_migrate_import_usage
fi

# Default from database to same as importing database.
if [[ -z $mi_from ]]; then
    mi_from=$mi_database
fi

# Check from value ( if passed in )
if [[ ! -z $mi_from ]] && [[ ! ${databases[@]} =~ $mi_from ]]; then
    mongo_migrate_import_usage
fi 

collections_dir=~/Desktop/collections/${mi_project}/${mi_from}

# Check collections value.
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
Collections: ${collections_array[@]}
Database: ${mi_database}
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

echo "" > ~/scripts/logs/mongo_migrate_import_logs.txt # Empties log.
for collection in "${collections_array[@]}"
do 
    # Check if we are truncating collection before importing.
    if [[ $mi_truncate = 'true' ]]; then
        if [[ $mi_verbose = 'true' ]]; then
            mongo_truncate $mi_project $mi_database 2>&1 | tee -a ~/scripts/logs/mongo_migrate_import_logs.txt
        else
            mongo_truncate $mi_project $mi_database &>> ~/scripts/logs/mongo_migrate_import_logs.txt
        fi
        echo "Truncated collection ${mi_collection} on remote database ${mi_database}."
    fi

    # Import each specified collection.
    if [[ $mi_verbose = 'true' ]]; then
        mongo_import $mi_project $mi_database $collection $collections_dir 2>&1 | tee -a ~/scripts/logs/mongo_migrate_import_logs.txt
    else
        mongo_import $mi_project $mi_database $collection $collections_dir &>> ~/scripts/logs/mongo_migrate_import_logs.txt
    fi

    echo "Imported ${collections_dir}/${collection}.json"
done

echo "Finished importing ${mi_database} collections from ${collections_dir}."