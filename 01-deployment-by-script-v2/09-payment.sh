#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: payment.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the payment component
# Description: Configures rabbitmq connectivity, updates service files, and validates payment service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for payment component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure payment Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh payment.sh
#############################################################################


COMPONENT="payment"
source ./common-script.sh

python_installation

app_user

app_code_download $COMPONENT

pip3 install -r requirements.txt &>>$LOG_FILE
VALIDATE $? "installing dependencies"

cp $INITIAL_REPO/payment.service /etc/systemd/system/payment.service
VALIDATE $? "adding service file"


systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable payment 
VALIDATE $? "enabling payment" 

systemctl start payment
VALIDATE $? "starting payment"

SHELL_END=$(date +%s)
time_taken $SHELL_END