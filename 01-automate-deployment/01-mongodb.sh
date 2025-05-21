#!/bin/bash

#############################################################################
# Author: ROYAL 
# Date: 20-05
# Version: v1
# Purpose: Automate mongodb configuration
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

USER_ID=$(id -u)

# logs setup
LOG_REPO="/var/log/ecommerce-app"
LOG_FILE="$LOG_REPO/mongodb.log"

echo -e "script is started execution at $G $(date) $N"  | tee -a $LOG_FILE

if [ $USER_ID -ne 0 ]
then
    echo -e "$R ERROR: need to provide sudo user access $N"
    exit 1
fi

# Validate command
VALIDATE(){
    if [ $1 -eq 0 ]
    then
        echo -e "$G $2 is Success $N"  | tee -a $LOG_FILE
    else
        echo -e "$R $2 is Failed $N"  | tee -a $LOG_FILE
        exit 1 
    fi    
}


mkdir -p "$LOG_REPO"
VALIDATE $? "creating log repo"

cp mongo.repo /etc/yum.repos.d/mongo.repo
VALIDATE $? "setup mongoDB repo file"

dnf install mongodb-org -y 
VALIDATE $? "installing mongoDB"

systemctl enable mongod 
VALIDATE $? "enabling mongoDB"

systemctl start mongod 
VALIDATE $? "starting mongoDB"

systemctl restart mongod
VALIDATE $? "restarting mongoDB"