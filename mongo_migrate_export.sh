#!/usr/local/bin/bash
# Might need these to use the mongo shell.
# brew services stop mongodb
# brew uninstall mongodb
# brew tap mongodb/brew
# brew install mongodb-community
# brew install mongodb/brew/mongodb-community-shell.
# brew services start mongodb-community

source ~/scripts/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script.
mongo_migrate_export_usage() {
	echo "Usage ${0} [p:d:c:vy]

Export full collections from a remote location to your local.

[-p project]            Specify which project this migration export is for.
[-d database]           Specify which database to export ( dev or prod ).
[-c collections]        Specify comma delimited collections to export. Specify 'all' to export all collections.
[-v verbose]            Enable verbosity for script.
[-y skip_confirmation]  Skip detail confirmation prompt." >&2
    exit 1
}

# Helper method that takes project name as $1 argument, database as $2 argument, collection as $3 argument, collections_dir as $4 argument.
mongo_export() {
    mongoexport \
    --host ${hosts[$1]} \
    --username ${usernames[$1]} \
    --password ${passwords[$1]} \
    --authenticationDatabase ${authentication_databases[$1]} \
    --db $2 \
    --collection $3 \
    --ssl \
    --type json \
    --out "${4}/${3}.json"
}

me_project=''
me_database=''
me_collections=''
me_verbose='false'
me_skip_confirmation='false'

OPTIND=1 # Reset for this script if using mongo_migrate.sh
while getopts p:d:c:vy OPTION
do
    case ${OPTION} in
        p) me_project="${OPTARG}";;
        d) me_database="${OPTARG}" ;;
        c) me_collections="${OPTARG}" ;;
        v) me_verbose='true' ;;
        y) me_skip_confirmation='true' ;;
        # Handle unknown cases here.
        *) mongo_migrate_export_usage ;;
    esac
done

#Check project value.
if [[ -z $me_project ]] || [[ ! ${!hosts[@]} =~ $me_project ]]; then
    mongo_migrate_export_usage
fi

# Check database value.
if [[ -z $me_database ]] || [[ ! ${databases[@]} =~ $me_database ]]; then
    mongo_migrate_export_usage
fi

# Check collections value.
if [[ -z $me_collections ]]; then
    mongo_migrate_export_usage
elif [[ $me_collections = 'all' ]]; then
    # Grab all collections available from server.
    me_collections=$( echo "show collections" | mongo "${mongoConnectionStrings[$me_project]}/${me_database}" --username ${usernames[$me_project]} --password ${passwords[$me_project]} --quiet )

    if [[ ${?} -ne 0 ]]; then
        echo "Unable to connect to ${me_project} database ${me_database}."
        exit 1
    fi

    # Convert each line into an array item.
    IFS=$'\n' read -r -d '' -a collections_array <<< $me_collections
    # for X in "${collections_array[@]}"; do echo "${X}"; done # Testing.
else
    # Convert comma delimited collection string into list.
    IFS=',' read -r -a collections_array <<< $me_collections
fi

me_collections_dir=~/Desktop/collections/${me_project}/${me_database}

echo "Export Details
Project: $me_project
Collections: ${collections_array[@]}
Database: $me_database
Directory: ${me_collections_dir}
"

# Prompt a confirmation on the details ( if not skipped ).
if [[ $me_skip_confirmation = 'false' ]]; then
    read -p 'Are these details correct?: (y/n)' me_confirmation
    if [[ ! $me_confirmation = 'y' ]]; then
        echo "Exiting script." >&2
        exit 1
    fi
fi

# Make dir to export json files to. Iterate each collection.
mkdir -p ${me_collections_dir}
echo "" > ~/scripts/logs/mongo_migrate_export_logs.txt # Empties log.
for collection in "${collections_array[@]}"
do
    if [[ $me_verbose = 'true' ]]; then
        mongo_export $me_project $me_database $collection $me_collections_dir 2>&1 | tee -a ~/scripts/logs/mongo_migrate_export_logs.txt
    else
        mongo_export $me_project $me_database $collection $me_collections_dir &>> ~/scripts/logs/mongo_migrate_export_logs.txt #Log details.
    fi
    echo "Exported ${me_collections_dir}/${collection}.json"
done

echo "Finished exporting ${me_database} collections to ${me_collections_dir}."