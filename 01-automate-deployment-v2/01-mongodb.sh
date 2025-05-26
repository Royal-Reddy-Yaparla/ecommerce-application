#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: mongodb.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the mongodb component
# Description: Configures MongoDB connectivity, and validates mongodb service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for mongodb component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure MongoDB Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh mongodb.sh
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
