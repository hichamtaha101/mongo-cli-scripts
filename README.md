# README #

The following repository is meant to provide shell utilities using the mongo CLI on a docker mongo container.
-    All command line outputs are stored in the `logs/` directory.
-    Collection imports and exports are stored in a `collections/${project}/${yyyy-mm-dd}` directory.

#### How to Setup ####

-    You'll need to have *docker* installed on your host machine for this project to work.
-    Run `docker-compose up -d` and using the docker UI, enter the CLI of the mongo container to start running the mongo scripts.
-    *If using windows, you may have to open the code base in a text editor and change the line endings from CRLF to LF for it to work in the container's linux environment.
-    Define your environment variables in a new `variables/mongo_variables.sh` file using the `variables/mongo_variables.sample.sh` file as a template.

### Available Commands ###




#### mongo_connect.sh

Connect to an atlas mongo database cluster.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | Alias         | Long          | Values(s)                                         |
|:------------------------|:--------------|:--------------|:--------------------------------------------------|
| project                 | ${1}          | n/a           | Specify the project you are connecting to.
| database                | ${2}          | n/a           | Specify the database you are connecting to.

#### Example CLI Snippet:

`mongo_connect.sh project dev`

This will connect to the dev database on the atlas mongo cluster for project.




--------------------------------------------
#### mongo_migrate_export.sh

Export full collections from a remote location to your local.

Collections will be exported into `./collections/${project}/${database}/`.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | Alias         | Long          | Values(s)                                         |
|:------------------------|:--------------|:--------------|:--------------------------------------------------|
| project                 | -p            | --project     | Specify which project this migration export is for.
| database                | -d            | --database    | Specify which database to export ( dev, int, staging, or production ).
| collections             | -c            | --collection  | Specify comma delimited collections to export. Specify 'all' to export all collections.
| verbose                 | -v            | --verbose     | Enable verbosity for script.
| skip_confirmation       | -s            | --skip        | Skip detail confirmation prompt.

#### Example CLI Snippet:

`mongo_migrate_export.sh -p project -d dev -c all -v -s` 

This will export ./scripts/collections/dev/*.json for the dev database, show all logs ( verbosity ), and skip detail confirmation.




--------------------------------------------
#### mongo_migrate_import.sh

Import full collection(s) from one project's exported database(s) to another.

Collections will be imported from `./collections/${project_from}/${database}/`.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | Alias         | Long           | Values(s)                                         |
|:------------------------|:--------------|:---------------|:--------------------------------------------------|
| project from            | -a            | --projectFrom  | Specify which project this migration import is from. Defaults to value of -p.
| project to              | -p            | --projectTo    | Specify which project this migration import is to.
| database from           | -f            | --databaseFrom | Specify which collection environment to import from. Defaults to value of -d.
| database to             | -d            | --databaseTo   | Specify which database to import into ( dev, int, staging, or production ).
| collections             | -c            | --collections  | Specify comma delimited collections to migrate. Specify 'all' to import all collections.
| truncate                | -t            | --truncate     | Whether to empty collection(s) before importing ( optional ).
| verbose                 | -v            | --verbose      | Enable verbosity for script.
| skip_confirmation       | -s            | --skip         | Skip detail confirmation prompt.

#### Example CLI Snippet:

`mongo_migrate_import.sh -p project -d dev -c users -t -v` 

This will import ./collections/dev/users.json into the dev database, and truncate existing records on the dev users collection.




--------------------------------------------
#### mongo_migrate.sh

Import full collection(s) from one destination to another.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | Alias         | Long          | Values(s)                                         |
|:------------------------|:--------------|:--------------|:--------------------------------------------------|
| project from            | -a            | --projectFrom  | Specify which project this migration is exporting from.
| project to              | -p            | --projectTo    | Specify which project this migration is importing to.
| database from           | -f            | --databaseFrom | Specify which collection environment to export from ( dev, int, staging, or production ).
| database to             | -d            | --databaseTo   | Specify which database to import to ( dev, int, staging, or production ).
| collections             | -c            | --collections  | Specify comma delimited collections to migrate. Specify 'all' to migrate all collections.
| truncate                | -t            | --truncate     | Whether to empty collection(s) before importing ( optional ).
| verbose                 | -v            | --verbose      | Enable verbosity for script.
| skip_confirmation       | -s            | --skip         | Skip detail confirmation prompt.

#### Example CLI Snippet:

`mongo_migrate.sh -p project -f dev -d int -c users -t` 

This will migrate dev users into integration users, and truncate existing records on the int users collection. 