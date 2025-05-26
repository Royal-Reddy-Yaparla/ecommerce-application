#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: distach.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the distach component
# Description: Configures rabbitmq connectivity, updates service files, and validates distach service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for distach component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure distach Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh distach.sh
#############################################################################


COMPONENT="dispatch"
source ./common-script.sh

golang_installation

app_user


# download application code
app_code_download $COMPONENT

go mod init dispatch &>>$LOG_FILE
VALIDATE $? "installing application dependencies"

go get 
go build
VALIDATE $? "get and build the application"

cp $INITIAL_REPO/dispatch.service /etc/systemd/system/dispatch.service
VALIDATE $? "adding service file"

systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable dispatch 
VALIDATE $? "enabling dispatch" 

systemctl start dispatch
VALIDATE $? "starting dispatch"

SHELL_END=$(date +%s)
time_taken $SHELL_END