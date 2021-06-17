#!/bin/bash

curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.34.0/install.sh | bash
. ~/.nvm/nvm.sh
nvm install v14.13.0 # Download stable version for sass compiler.
npm install yarn -g
npm install pm2 -g