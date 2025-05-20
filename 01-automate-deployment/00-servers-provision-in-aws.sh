#!/bin/bash

#############################################################################
# Author: ROYAL 
# Date: 20-05
# Version: v1
# Purpose: Automate the process of creating EC2 instances and Route53 records
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)

# logs setup
LOG_REPO="/var/log/servers-provison"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_REPO/$SCRIPT_NAME.log"
# echo "$LOG_FILE"

if [ $USER_ID -ne 0 ]
then
    echo -e "$R ERROR: need to provide sudo user access $N"
    exit 1
fi

# Validate command
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$2 is Success $N"  | tee -a $LOG_FILE
    else
        echo -e "$2 is Failed $N"  | tee -a $LOG_FILE
        exit 1 
    fi    
}


mkdir -p "$LOG_REPO"
VALIDATE() $? "creating log repo"




