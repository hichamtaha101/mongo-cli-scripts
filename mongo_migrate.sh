#!/usr/local/bin/bash

script_dir=$( dirname "${BASH_SOURCE[0]}" )
source ~$script_dir/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script.
mongo_migrate_usage() {
	echo "Usage ${0} [p:d:c:f:tvy]

Import full collection(s) database one destination to another.

[-a project from]       Specify which project this migration is exporting from.
[-p project to]         Specify which project this migration is importing to.
[-f database from]      Speicfy which database to export ( dev or prod ).
[-d database to]        Specify which database to import into ( dev or prod ).
[-c collections]        Specify comma delimited collections to migrate. Specify 'all' to migrate all collections.
[-t truncate]           Whether to empty collection(s) before importing ( optional ).
[-v verbose]            Enable verbosity for the script.
[-y skip_confirmation]  Skip detail confirmation prompt." >&2
    exit 1
}

# Store variables and their defaults
mm_project_from=''
mm_project_to=''
mm_database_from=''
mm_database_to=''
collections=''
truncate=''
verbose=''
skip_confirmation=''

OPTIND=1 # Reset for this script
while getopts a:p:d:c:f:tvy OPTION
do
    case ${OPTION} in
        a) mm_project_from="${OPTARG}" ;;
        p) mm_project_to="${OPTARG}" ;;
        f) mm_database_from="${OPTARG}" ;;
        d) mm_database_to="${OPTARG}" ;;
        c) collections="${OPTARG}" ;;
        t) truncate='-t' ;;
        v) verbose='-v' ;;
        y) skip_confirmation='-y' ;;

        # Handle unknown cases here.
        *) mongo_migrate_usage ;;
    esac
done

#Check project to value.
if [[ -z $mm_project_to ]] || [[ ! ${hosts[@]} =~ $mm_project_to ]]; then
    echo "Invalid -p option: ${mm_project_to}."
    mongo_migrate_usage
fi

# Default project from to the same as project to.
if [[ -z $mm_project_from ]]; then
    mm_project_from=$mm_project_to
fi
# Ensure project from is a legitimate value.
if [[ ! ${!hosts[@]} =~ $mm_project_from ]]; then
    echo "Invalid -a option: ${mm_project_from}."
    mongo_migrate_import_usage
fi

# Check mm_database_to value.
if [[ -z $mm_database_to ]] || [[ ! ${databases[@]} =~ $mm_database_to ]]; then
    echo "Invalid -d option: ${mm_database_to}."
    mongo_migrate_usage
fi

# Check mm_database_from mm_database_to value
if [[ -z $mm_database_from ]] || [[ ! ${databases[@]} =~ $mm_database_from ]]; then
    echo "Invalid -f option: ${mm_database_from}."
    mongo_migrate_usage
fi 

# Check collections has a value.
if [[ -z $collections ]]; then
    echo "Invalid -c option: ${collections}."
    mongo_migrate_usage
fi

# Run migration export
source ~/scripts/mongo_migrate_export.sh -p $mm_project_from -d $mm_database_from -c $collections $verbose $skip_confirmation

# Check if things ran smooth before continuing to import.
if [[ ${?} -ne 0 ]]; then
    echo "Failed to export ${mm_project_from} collection(s) from ${mm_database_from} database." >&2
    exit 1
fi

# Run migration import
source ~/scripts/mongo_migrate_import.sh -a $mm_project_from -p $mm_project_to -f $mm_database_from -d $mm_database_to -c $collections $verbose $skip_confirmation $truncate
if [[ ${?} -ne 0 ]]; then
    echo "Failed to import collections to ${mm_project_to} database ${mm_database_to}." >&2
    exit 1
fi
