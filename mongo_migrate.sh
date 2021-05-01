#!/bin/bash

script_dir=$( dirname "${BASH_SOURCE[0]}" )
source ${script_dir}/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script.
mongo_migrate_usage() {
  echo "Usage ${0} [p:d:c:f:tvs]

Import full collection(s) database one destination to another.

[-a|--projectFrom   project from]       Specify which project this migration is exporting from.
[-p|--projectTo     project to]         Specify which project this migration is importing to.
[-f|--databaseFrom  database from]      Specify which database to export ( dev or prod ).
[-d|--databaseTo    database to]        Specify which database to import into ( dev or prod ).
[-c|--collections   collections]        Specify comma delimited collections to migrate. Specify 'all' to migrate all collections.
[-t|--truncate      truncate]           Whether to empty collection(s) before importing ( optional ).
[-v|--verbose       verbose]            Enable verbosity for the script.
[-s|--skip          skip_confirmation]  Skip detail confirmation prompt." >&2
    exit 1
}

# Store variables and their defaults
mm_project_from=''
mm_project_to=''
mm_database_from=''
mm_database_to=''
mm_collections=''
mm_truncate=''
mm_verbose=''
mm_skip_confirmation=''
mm_positional_params=''

while (( "${#}" )); do
  case ${1} in
    -a|--projectFrom)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != '-' ]]; then mm_project_from="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_usage; fi ;;
    -p|--projectTo)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != '-' ]]; then mm_project_to="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_usage; fi ;;
    -f|--databaseFrom)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != '-' ]]; then mm_database_from="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_usage; fi ;;
    -d|--databaseTo)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != '-' ]]; then mm_database_to="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_usage; fi ;;
    -c|--collections)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != '-' ]]; then mm_collections="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_usage; fi ;;
    -t|--truncate) mm_truncate="--truncate"; shift ;;
    -v|--verbose) mm_verbose="--verbose"; shift ;;
    -s|--skip) mm_skip_confirmation="--skip"; shift ;;
    # Handle unknown flags.
    -*|--*) echo "Error: Unsupported flag ${1}" >&2; mongo_migrate_usage ;;
    # Store the rest of the positional parameters.
    *) mm_positional_params="${mm_positional_params} ${1}"; shift ;;
  esac
done


# Map project names to mongo key.
if [[ -v "projects_mapped[${mm_project_to}]" ]]; then mm_project_to=${projects_mapped[$mm_project_to]}; fi
if [[ -v "projects_mapped[${mm_project_from}]" ]]; then mm_project_from=${projects_mapped[$mm_project_from]}; fi

# Check project_to value.
if [[ -z $mm_project_to ]] || [[ ! -v "hosts[${mm_project_to}]" ]]; then echo "Invalid -p option: ${mm_project_to} ${!hosts[@]}."; mongo_migrate_usage; fi

# Default project_from to the same as project to.
if [[ -z $mm_project_from ]]; then mm_project_from=$mm_project_to; fi

# Ensure project_from is a legitimate value.
if [[ ! -v "hosts[${mm_project_from}]" ]]; then echo "Invalid -a option: ${mm_project_from}."; mongo_migrate_import_usage; fi

# Check mm_database_to value.
if [[ -z $mm_database_to ]] || [[ ! -v "databases[${mm_database_to}]" ]]; then echo "Invalid -d option: ${mm_database_to}."; mongo_migrate_usage; fi
if [[ ${mm_database_to} = 'prod' ]]; then echo "You are not allowed to import into production databases." >&2; exit 1; fi

# Check mm_database_from mm_database_to value
if [[ -z $mm_database_from ]] || [[ ! -v "databases[${mm_database_from}]" ]]; then echo "Invalid -f option: ${mm_database_from}."; mongo_migrate_usage; fi

# Check collections has a value.
if [[ -z $mm_collections ]]; then echo "Invalid -c option: ${mm_collections}."; mongo_migrate_usage; fi

# Run migration export
${script_dir}/mongo_migrate_export.sh -p $mm_project_from -d $mm_database_from -c $mm_collections $mm_verbose $mm_skip_confirmation

# Check if things ran smooth before continuing to import.
if [[ ${?} -ne 0 ]]; then
    echo "Failed to export ${mm_project_from} collection(s) from ${mm_database_from} database." >&2
    exit 1
fi

# Run migration import
${script_dir}/mongo_migrate_import.sh -a $mm_project_from -p $mm_project_to -f $mm_database_from -d $mm_database_to -c $mm_collections $mm_verbose $mm_skip_confirmation $mm_truncate
if [[ ${?} -ne 0 ]]; then
    echo "Failed to import collections to ${mm_project_to} database ${mm_database_to}." >&2
    exit 1
fi
