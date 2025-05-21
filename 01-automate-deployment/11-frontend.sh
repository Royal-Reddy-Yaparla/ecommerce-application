#!/bin/bash

#############################################################################
# Author: ROYAL 
# Date: 20-05
# Version: v1
# Purpose: Automate frontend configuration
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
INITIAL_REPO=$PWD

USER_ID=$(id -u)

# logs setup
LOG_REPO="/var/log/ecommerce-app"
LOG_FILE="$LOG_REPO/frontend.log"

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


dnf module disable nginx -y &>>$LOG_FILE
VALIDATE $? "disabling default nginx package" 

dnf module enable nginx:1.24 -y &>>$LOG_FILE
VALIDATE $? "enabling nginx:1.24 package" 

dnf install nginx -y &>>$LOG_FILE
VALIDATE $? "installing default nginx package" 

systemctl enable nginx 
VALIDATE $? "enabling nginx" 

systemctl start nginx 
VALIDATE $? "starting nginx" 

rm -rf /usr/share/nginx/html/* 
VALIDATE $? "removing nginx default files"

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend-v3.zip
VALIDATE $? "downloading application code" 

cd /usr/share/nginx/html 
VALIDATE $? "changing repo to /usr/share/nginx/html " 

unzip /tmp/frontend.zip &>>$LOG_FILE
VALIDATE $? "unzipping application code" 


cp $INITIAL_REPO/nginx.conf /etc/nginx/nginx.conf
VALIDATE $? "coping config file" 

systemctl restart nginx 
VALIDATE $? "restarting nginx service" 