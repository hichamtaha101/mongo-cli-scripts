#!/bin/bash

# Define constants and initialize mapped shell variables.
databases=(dev prod)

declare -A hosts
declare -A usernames
declare -A passwords
declare -A authentication_databases
declare -A mongoConnectionStrings
declare -A isMongoSSL
declare -A projects_mapped

# Map project names
projects_mapped[bittreo_platform]="project_name"

# Your project environemnt(s) credentials
hosts[project_name]="project_name-cluster-shard-00-02.xvaaw.mongodb.net:27017"              # This is just a sample.
mongoConnectionStrings[project_name]="mongodb+srv://project_name-cluster.xvaaw.mongodb.net" # This is just a sample.
usernames[project_name]="admin"                                                             # This is just a sample.
passwords[project_name]="Zzzrqn6r9f2Dkj9yAA"                                                # This is just a sample.
authentication_databases[project_name]="admin"                                              # This is just a sample.
isMongoSSL[project_name]="--ssl"                                                            # This is just a sample.

# Local example
hosts[local]="localhost:27017"
mongoConnectionStrings[local]="mongodb://localhost:27017"
usernames[local]="admin"
passwords[local]="admin"
authentication_databases[local]="admin"
isMongoSSL[local]=""
