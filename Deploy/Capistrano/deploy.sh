#!/bin/bash

#Filename : deploy.sh

# Script for executing cap via cronjob

cd $HOME/staging/current/Deploy/Capistrano
/usr/bin/cap staging conditional_deploy

