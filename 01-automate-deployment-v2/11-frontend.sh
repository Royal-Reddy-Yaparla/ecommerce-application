#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: frontend.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the frontend component
# Description: pdates service files, and validates frontend service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for frontend component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure frontend Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh frontend.sh
#############################################################################


COMPONENT="frontend"
source ./common-script.sh

nginx_installation

systemctl enable nginx 
VALIDATE $? "enabling nginx" 

systemctl start nginx 
VALIDATE $? "starting nginx" 

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
VALIDATE $? "removing nginx default files"

# download application code
app_code_download $COMPONENT

cp $INITIAL_REPO/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "coping config file" 

systemctl restart nginx 
VALIDATE $? "restarting nginx service" 

SHELL_END=$(date +%s)
time_taken $SHELL_END