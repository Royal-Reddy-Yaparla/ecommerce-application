#!/bin/bash

#############################################################################
# Author: ROYAL 
# Date: 21-05-2025
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
        echo -e "$2 is $G Success $N"  | tee -a $LOG_FILE
    else
        echo -e "$2 is $G Failed $N"  | tee -a $LOG_FILE
        exit 1 
    fi    
}


mkdir -p "$LOG_REPO"
VALIDATE $? "creating log repo"

cp mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "setup mongoDB repo file" 

# dnf list installed mongodb &>>$LOG_FILE
# VALIDATE $? "installing mongoDB"  

# if [ $? -eq 0 ]
# then 
#     echo -e "$Y mongodb already installed $N"  | tee -a $LOG_FILE
#     exit 1
# fi

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongoDB" 

systemctl enable mongod &>>$LOG_FILE
VALIDATE $? "enabling mongoDB" 

systemctl start mongod &>>$LOG_FILE
VALIDATE $? "starting mongoDB"

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf &>>$LOG_FILE
VALIDATE $? "updating listen address" 

systemctl restart mongod &>>$LOG_FILE
VALIDATE $? "restarting mongoDB"