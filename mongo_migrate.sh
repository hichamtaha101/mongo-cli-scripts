#!/usr/local/bin/bash

source ~/scripts/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script.
mongo_migrate_usage() {
	echo "Usage ${0} [p:d:c:f:tvy]

Import full collection(s) from one destination to another.

[-p project]            Specify which project this migration is for.
[-f from]               Speicfy which collection environment to export from ( dev or prod ).
[-d database]           Specify which database to import into ( dev or prod ).
[-c collections]        Specify comma delimited collections to migrate. Specify 'all' to migrate all collections.
[-t truncate]           Whether to empty collection(s) before importing ( optional ).
[-v verbose]            Enable verbosity for the script.
[-y skip_confirmation]  Skip detail confirmation prompt." >&2
    exit 1
}

# Store variables and their defaults
project=''
from=''
database=''
collections=''
truncate=''
verbose=''
skip_confirmation=''

OPTIND=1 # Reset for this script
while getopts p:d:c:f:tvy OPTION
do
    case ${OPTION} in
        p) project="${OPTARG}" ;;
        f) from="${OPTARG}" ;;
        d) database="${OPTARG}" ;;
        c) collections="${OPTARG}" ;;
        t) truncate='-t' ;;
        v) verbose='-v' ;;
        y) skip_confirmation='-y' ;;

        # Handle unknown cases here.
        *) mongo_migrate_usage ;;
    esac
done

#Check project value.
if [[ -z $project ]] || [[ ! ${hosts[@]} =~ $project ]]; then
    mongo_migrate_usage
fi

# Check database value.
if [[ -z $database ]] || [[ ! ${databases[@]} =~ $database ]]; then
    mongo_migrate_usage
fi

# Check from database value
if [[ -z $from ]] || [[ ! ${databases[@]} =~ $from ]]; then
    mongo_migrate_usage
fi 

# Check collections has a value.
if [[ -z $collections ]]; then
    mongo_migrate_usage
fi

# Run migration export
source ~/scripts/mongo_migrate_export.sh -p $project -d $from -c $collections $verbose $skip_confirmation

# Check if things ran smooth before continuing to import.
if [[ ${?} -ne 0 ]]; then
    echo "Failed to export collections from ${project} database ${from}." >&2
    exit 1
fi

# Run migration import
source ~/scripts/mongo_migrate_import.sh -p $project -d $database -c $collections $verbose $skip_confirmation $truncate
if [[ ${?} -ne 0 ]]; then
    echo "Failed to import collections to ${project} database ${database}." >&2
    exit 1
fi
