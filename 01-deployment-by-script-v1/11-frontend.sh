#!/bin/bash
SHELL_START=$(date +%s)


#############################################################################
# Managed_By: ROYAL 
# Date: 21-05-2025
# Version: v1
# Purpose: Automate frontend configuration
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"
echo -e "scripted stated at::$Y $(date) $N"

INITIAL_REPO=$PWD

USER_ID=$(id -u)

# logs setup
LOG_REPO="/var/log/ecommerce-app"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_REPO/$SCRIPT_NAME.log"

mkdir -p "$LOG_REPO"
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

rm -rf /usr/share/nginx/html/*  &>>$LOG_FILE
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

SHELL_END=$(date +%s)
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"