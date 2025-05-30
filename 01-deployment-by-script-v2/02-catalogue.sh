#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: catalogue.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the catalogue component
# Description: Configures mongodb connectivity, updates service files, and validates catalogue service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for catalogue component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure MongoDB Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh catalogue.sh
#############################################################################

COMPONENT="catalogue"
source ./common-script.sh

# nodejs configuration
nodejs_installation

# create app's repo and user
app_user

# download application code
app_code_download $COMPONENT

npm install  &>>$LOG_FILE
VALIDATE $? "installing application dependencies"

cp $INITIAL_REPO/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "adding service file"

systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable catalogue 
VALIDATE $? "enabling catalogue" 

systemctl start catalogue
VALIDATE $? "starting catalogue"

# make sure connection with mongodb
cp $INITIAL_REPO/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "setup mongoDB repo file" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongoDB" 


mongosh --host mongodb.royalreddy.site </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "loading master date" 

# mongosh --host mongodb.royalreddy.site
# VALIDATE $? "connecting mongodb server" 

SHELL_END=$(date +%s)
time_taken $SHELL_END