# README #

The following repository is meant to provide helpful CLI commands written for the bash shell.

### How do I get set up? ###

* Clone the repository into your home directory. Example `/Users/hicham.taha/scripts`.

* You'll need to grab configs for the `variables/mongo_variables.sh.` file from one of the developers.

* You'll also need to grab any ec2 related private keys from one of the developers.

* Run `chmod 400 ~/scripts/keys/*` to allow the keys to be used by the script.

* Open up your linux user's bash_profile and adjust the environment path variable to account for the scripts' location. `PATH=/usr/bin:/bin:/usr/sbin:/sbin:/usr/local/bin:/usr/X11/bin:${HOME}/scripts; export PATH`. Note that each colon delimits a separate path to read from. The part that matters in this example is `${HOME}/scripts`.

* Run the following for the latest bash `brew install bash`. Install brew into your machine if you do not have it already.

* Source your bash_profile by running `source ~/.bash_profile`.

### Available Commands ###

#### ssh_ec2.sh

Connect to an AWS EC2 instance.

More details can be found inside variables/ssh_variables.sh

#### Script parameters:

| Argument(s)             | alias         | Values(s)                                                         |
|:------------------------|:--------------|:------------------------------------------------------------------|
| instance                | -i            | Specify the instance you are connecting to.

#### Example CLI Snippet:

`ssh_ec2 -i chatso-dev`

This will connect to the chatso dev ec2 instance on aws using the private key found in keys/dev-chatso.pem




--------------------------------------------
#### mongo_connect.sh

Connect to an atlas mongo database cluster.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | alias         | Values(s)                                                         |
|:------------------------|:--------------|:------------------------------------------------------------------|
| project                 | ${1}          | Specify the project you are connecting to.
| database                | ${2}          | Specify the database you are connecting to.

#### Example CLI Snippet:

`mongo_connect.sh chatso dev`

This will connect to the dev database on the atlas mongo cluster for chatso.




--------------------------------------------
#### mongo_migrate_export.sh

Export full collections from a remote location to your local.

Collections will be exported into `~/Desktop/collections/${project}/${database}/`.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | alias         | Values(s)                                                         |
|:------------------------|:--------------|:------------------------------------------------------------------|
| project                | -p             | Specify which project this migration export is for.
| database               | -d             | Specify which database to export ( dev, int, staging, or production ).
| collections            | -c             | Specify comma delimited collections to export. Specify 'all' to export all collections.
| verbose                | -v             | Enable verbosity for script.
| skip_confirmation      | -y             | Skip detail confirmation prompt.

#### Example CLI Snippet:

`mongo_migrate_export.sh -p chatso -d dev -c all -v -y` 

This will export ~/Desktop/collections/dev/*.json for the dev database, show all logs ( verbosity ), and skip detail confirmation.




--------------------------------------------
#### mongo_migrate_import.sh

Import full collections from a your local to a remote location.

Collections will be imported from `~/Desktop/collections/${project}/${database}/`.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | alias         | Values(s)                                                         |
|:------------------------|:--------------|:------------------------------------------------------------------|
| project                | -p             | Specify which project this migration import is for.
| database               | -d             | Specify which database to import ( dev, int, staging, or production ).
| collections            | -c             | Specify comma delimited collections to migrate. Specify 'all' to import all collections.
| from                   | -f             | Specify which collection environment to import from. Defaults to -d value.
| truncate               | -t             | Whether to empty collection(s) before importing ( optional ).
| verbose                | -v             | Enable verbosity for script.
| skip_confirmation      | -y             | Skip detail confirmation prompt.

#### Example CLI Snippet:

`mongo_migrate_import.sh -p chatso -d dev -c users -t -v` 

This will import ~/Desktop/collections/dev/users.json into the dev database, and truncate existing records on the dev users collection.




--------------------------------------------
#### mongo_migrate.sh

Import full collection(s) from one destination to another.

More details can be found inside variables/mongo_variables.sh

#### Script parameters:

| Argument(s)             | alias         | Values(s)                                                         |
|:------------------------|:--------------|:------------------------------------------------------------------|
| project                | -p             | Specify which project this migration is for.
| database               | -d             | Specify which database to import ( dev, int, staging, or production ).
| collections            | -c             | Specify comma delimited collections to migrate. Specify 'all' to migrate all collections.
| from                   | -f             | Specify which collection environment to export from ( dev, int, staging, or production ).
| truncate               | -t             | Whether to empty collection(s) before importing ( optional ).
| verbose                | -v             | Enable verbosity for script.
| skip_confirmation      | -y             | Skip detail confirmation prompt.

#### Example CLI Snippet:

`mongo_migrate.sh -p chatso -f dev -d int -c users -t` 

This will migrate dev users into integration users, and truncate existing records on the int users collection. 