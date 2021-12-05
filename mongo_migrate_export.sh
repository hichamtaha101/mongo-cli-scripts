#!/bin/bash

# --------------------------------------------------------------------------------------------
# [Hicham Taha] mongo_migrate_export.sh
#				Export database collection(s) from one project's database to a project's collections 
#       directory.
# --------------------------------------------------------------------------------------------

script_dir=$( dirname "${BASH_SOURCE[0]}" )
source ${script_dir}/variables/mongo_variables.sh

# Helper method that dispalys the usage of this script.
mongo_migrate_export_usage() {
  echo "Usage ${0} [p:d:c:vs]

Export full collections from a remote location to your local.

[-p|--project     project to]         Specify which project this migration export is for.
[-d|--database    database]           Specify which database to export ( dev or prod ).
[-c|--collections collections]        Specify comma delimited collections to export. Specify 'all' to export all collections.
[-v|--verbose     verbose]            Enable verbosity for script.
[-s|--skip        skip_confirmation]  Skip detail confirmation prompt." >&2
  exit 1
}

# Helper method that takes project name as $1 argument, database as $2 argument, collection as $3 argument, collections_dir as $4 argument.
mongo_export() {
  mongoexport \
  --host ${hosts[$1]} \
  --username ${usernames[$1]} \
  --password ${passwords[$1]} \
  --authenticationDatabase ${authentication_databases[$1]} \
  ${isMongoSSL[$1]} \
  --db $2 \
  --collection $3 \
  --type json \
  --out "${4}/${3}.json"
}

me_positional_params=''
me_project_to=''
me_database_from=''
me_collections=''
me_verbose='false'
me_skip_confirmation='false'

# Parse all parameters
while (( "${#}" )); do
  case "${1}" in
    -p|--project)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != "-" ]]; then me_project_to="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_export_usage; fi ;;
    -d|--database)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != "-" ]]; then me_database_from="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_export_usage; fi ;;
    -c|--collections)
      if [[ -n "${2}" ]] && [[ ${2:0:1} != "-" ]]; then me_collections="${2}"; shift 2
      else echo "Error: Argument for ${1} is missing" >&2; mongo_migrate_export_usage; fi ;;
    -v|--verbose) me_verbose='true'; shift ;;
    -s|--skip) me_skip_confirmation='true'; shift ;;
    # Handle unknown flags.
    -*|--*=) echo "Error: Unsupported flag ${1}" >&2; mongo_migrate_export_usage ;;
    # Store the rest of the positional parameters.
    *) me_positional_params="${me_positional_params} ${1}"; shift ;;
  esac
done

# Map project names to mongo key.
if [[ -v "projects_mapped[${me_project_to}]" ]]; then me_project_to=${projects_mapped[$me_project_to]}; fi

#Check project value.
if [[ -z $me_project_to ]] || [[ ! -v "hosts[${me_project_to}]" ]]; then echo "Invalid -p option: ${me_project_to}."; mongo_migrate_export_usage; fi

# Check database value.
if [[ -z $me_database_from ]] || [[ ! -v "databases[${me_database_from}]" ]]; then echo "Invalid -d option: ${me_database_from}."; mongo_migrate_export_usage; fi

# Check collections value.
if [[ -z $me_collections ]]; then
  echo "Invalid -c option: ${me_collections}."
  mongo_migrate_export_usage
elif [[ $me_collections = 'all' ]]; then
  # Grab all collections available from server.
  me_collections=$( echo "show collections" | mongo "${mongoConnectionStrings[$me_project_to]}/${me_database_from}?authSource=admin" --username ${usernames[$me_project_to]} --password ${passwords[$me_project_to]} --quiet )

  if [[ ${?} -ne 0 ]]; then
    echo "Unable to connect to ${mongoConnectionStrings[$me_project_to]}/${me_database_from}."
    exit 1
  fi

  # Convert each line into an array item.
  IFS=$'\n' read -r -d '' -a collections_array <<< $me_collections
  # for X in "${collections_array[@]}"; do echo "${X}"; done # Testing.
else
  # Convert comma delimited collection string into list.
  IFS=',' read -r -a collections_array <<< $me_collections
fi

me_collections_dir=${script_dir}/collections/${me_project_to}/${me_database_from}/$( date "+%Y-%m-%d" )

echo "Export Details
Project: $me_project_to
Database From: $me_database_from
Directory: ${me_collections_dir}
Collections: ${collections_array[@]}
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
me_log_file=$( date "+%Y_%m_%d" )_mongo_migrate_export_logs.txt
echo "" > ${script_dir}/logs/${me_log_file} # Empties log.
for collection in "${collections_array[@]}"
do
  if [[ $me_verbose = 'true' ]]; then
    mongo_export $me_project_to $me_database_from $collection $me_collections_dir 2>&1 | tee -a ${script_dir}/logs/${me_log_file}
  else
    mongo_export $me_project_to $me_database_from $collection $me_collections_dir &>> ${script_dir}/logs/${me_log_file} #Log details.
  fi
  echo "Exported ${me_collections_dir}/${collection}.json"
done

echo "Finished exporting ${me_database_from} collections to ${me_collections_dir}."
