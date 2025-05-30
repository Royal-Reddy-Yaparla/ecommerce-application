#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: user.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the user component
# Description: Configures mongodb and redis connectivity, updates service files, and validates user service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for user component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure user Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh user.sh
#############################################################################



COMPONENT="user"
source ./common-script.sh

# nodejs configuration
nodejs_installation

# create app's repo and user
app_user

# download application code
app_code_download $COMPONENT

npm install  &>>$LOG_FILE
VALIDATE $? "installing application dependencies"

cp $INITIAL_REPO/user.service /etc/systemd/system/user.service
VALIDATE $? "adding service file"

systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable user 
VALIDATE $? "enabling user" 

systemctl start user
VALIDATE $? "starting user"

SHELL_END=$(date +%s)
time_taken $SHELL_END