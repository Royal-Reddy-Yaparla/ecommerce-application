#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Script Name: cart.sh
# Managed By: Royal Reddy
# Date: 2025-05-25
# Version: 2.0
# Purpose: Automates configuration and deployment of the cart component
# Description: Configures redis and catalogue connectivity, updates service files, and validates cart service
# Author: Royal Reddy
# Changelog:
#   - v1.0 (2025-05-21): Initial script for cart component setup
#   - v2.0 (2025-05-25): Optimized for common script integration, added error handling
# Notes:
#   - Ensure cart Route53 record is updated before execution
#   - Run as root or with sudo privileges
# Usage: sudo sh cart.sh
#############################################################################


COMPONENT="cart"
source ./common-script.sh

# nodejs configuration
nodejs_installation

# create app's repo and user
app_user

# download application code
app_code_download $COMPONENT

npm install  &>>$LOG_FILE
VALIDATE $? "installing application dependencies"

cp $INITIAL_REPO/cart.service /etc/systemd/system/cart.service
VALIDATE $? "adding service file"

systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable cart 
VALIDATE $? "enabling cart" 

systemctl start cart
VALIDATE $? "starting cart"

SHELL_END=$(date +%s)
time_taken $SHELL_END