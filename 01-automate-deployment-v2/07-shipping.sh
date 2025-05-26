#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: shipping.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the shipping component
# Description: Configures mysql connectivity, updates service files, and validates shipping service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for shipping component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure shipping Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh shipping.sh
#############################################################################
COMPONENT="shipping"
source ./common-script.sh

# java and maven configuration
maven_installation

# create app's repo and user
app_user

# download application code
app_code_download $COMPONENT

mvn clean package &>>$LOG_FILE
VALIDATE $? "mavan build and package"

mv target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE $? "renaming package"

cp $INITIAL_REPO/shipping.service /etc/systemd/system/shipping.service
VALIDATE $? "adding service file"


systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable shipping 
VALIDATE $? "enabling shipping" 

systemctl start shipping
VALIDATE $? "starting shipping"


dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Install MySQL"


mysql -h mysql.royalreddy.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.royalreddy.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.royalreddy.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.royalreddy.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading master data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi


systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"

SHELL_END=$(date +%s)
time_taken $SHELL_END