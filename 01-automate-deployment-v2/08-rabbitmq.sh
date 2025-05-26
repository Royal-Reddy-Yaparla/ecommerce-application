#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: rabbitmq.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the rabbitmq component
# Description: Configures rabbitmq connectivity, and validates rabbitmq service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for rabbitmq component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure rabbitmq Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh rabbitmq.sh
#############################################################################

source ./common-script.sh

cp $INITIAL_REPO/rabbitmq.repo /etc/yum.repos.d/rabbitmq.repo
VALIDATE $? "coping rabbitmq repo file" 

dnf install rabbitmq-server -y &>>$LOG_FILE
VALIDATE $? "installing rabbitmq"

systemctl enable rabbitmq-server &>>$LOG_FILE
VALIDATE $? "enabling rabbitmq"

systemctl start rabbitmq-server &>>$LOG_FILE
VALIDATE $? "starting rabbitmq"

rabbitmqctl add_user roboshop $RABBITMQ_PASSWD &>>$LOG_FILE
rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>>$LOG_FILE


SHELL_END=$(date +%s)
time_taken $SHELL_END
