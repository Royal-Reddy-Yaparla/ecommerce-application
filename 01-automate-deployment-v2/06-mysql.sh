#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: mysql.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the mysql component
# Description: Configures mysql connectivity, and validates mysql service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for mysql component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure mysql Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh mysql.sh
#############################################################################


source ./common-script.sh

dnf install mysql-server -y &>>$LOG_FILE
VALIDATE $? "installing mysql" 


systemctl enable mysqld 
VALIDATE $? "enabling mysqld" 

systemctl start mysqld  
VALIDATE $? "starting mysqld"


mysql_secure_installation --set-root-pass RoboShop@1
VALIDATE $? "setting up root password"

SHELL_END=$(date +%s)
time_taken $SHELL_END
