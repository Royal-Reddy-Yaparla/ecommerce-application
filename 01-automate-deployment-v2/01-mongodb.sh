#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Author: ROYAL 
# Date: 25-05-2025
# Version: v2
# Purpose: Automate mongodb configuration
# update: optimize shell-script as part common script developed
#############################################################################


source ./common-script.sh

cp mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "setup mongoDB repo file" 


dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongoDB" 

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongoDB" 

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "updating listen address" 

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongoDB"

SHELL_END=$(date +%s)
time_taken $SHELL_END
