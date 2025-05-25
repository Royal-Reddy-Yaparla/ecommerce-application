#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Author: ROYAL 
# Date: 25-05-2025
# Version: v2
# Purpose: Automate user-component configuration
# update: optimize shell-script as part common script developed
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