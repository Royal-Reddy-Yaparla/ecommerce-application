#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: redis.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the redis component
# Description: Configures redis connectivity, and validates redis service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for redis component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure redis Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh redis.sh
#############################################################################


source ./common-script.sh


dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling default redis package"


dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling redis:7 package" 

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis" 


sed -i -e 's/127.0.0.1/0.0.0.0/g' -e '/protected-mode/ c protected-mode no' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "updating listen address"


systemctl enable redis 
VALIDATE $? "enabling redis" 

systemctl start redis 
VALIDATE $? "starting redis"


SHELL_END=$(date +%s)
time_taken $SHELL_END