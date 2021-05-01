# README #

The following repository is meant to provide helpful CLI commands written for the bash shell.
The following script is preferred for UNIX based environments. Untested on windows.
### How do I get set up? ###

#### Mac OS Setup ####

-   You'll need to have *mongo*, *git/bash* installed on your host machine for this project to work.
-   Clone the repository into your home directory. Example `/Users/hicham.taha/scripts`.
-   You'll need to grab configs for the `variables/mongo_variables.sh.` file from one of the developers.
-   You'll also need to grab any ec2 related private keys from one of the developers.
-   If you've got keys, run `chmod 400 ~/scripts/keys/*` to allow the keys to be used by the script.
-   Open up your linux user's bash_profile and adjust the environment path variable to account for the scripts' location. `PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:${HOME}/scripts; export PATH`. Note that each colon delimits a separate path to read from. The part that matters in this example is `${HOME}/scripts`.
-   Make sure you have the latest version of bash on your local user. Click [here](https://itnext.io/upgrading-bash-on-macos-7138bd1066ba) for details. This will allow the following scripts to use the /usr/local/bin/bash interpreter for associative arrays.
-   Source your bash_profile by running `source ~/.bash_profile`.
-   Run the command `replace_interpreter.sh \\/bin\\/bash \\/usr\\/local\\/bin\\/bash` in the repository directory.
-   To revert the above, run the command `/bin/bash replace_interpreter.sh \\/usr\\/local\\/bin\\/bash \\/bin\\/bash` in the repository directory.
#### Docker Setup ####

-   You'll need to have *docker* installed on your host machine for this project to work.
-   Run `docker-compose up -d` and using the docker UI, enter the CLI of the mongo container to start running the mongo scripts.
-   *If using a windows, you may have to open the code base in a text editor and change the line endings from CRLF to LF for it to work in the container's linux environment.
### Available Commands ###

#### ssh_ec2.sh

Connect to an AWS EC2 instance.

More details can be found inside variables/ssh_variables.sh

#### Script parameters:

| Argument(s)             | Alias         | Long          | Values(s)                                                         |
|:------------------------|:--------------|:--------------|:--------------------------------------------------|
| instance                | -i            | n/a           | Specify the instance you are connecting to.

#### Example CLI Snippet:

`ssh_ec2 -i project-dev`

This will connect to the project dev ec2 instance on aws using the private key found in keys/dev-project.pem




--------------------------------------------
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