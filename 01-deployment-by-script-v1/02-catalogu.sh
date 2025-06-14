#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Managed_By: ROYAL 
# Date: 21-05-2025
# Version: v1
# Purpose: Automate user-component configuration
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




dnf module disable nodejs -y &>>$LOG_FILE
VALIDATE $? "disabling default nodejs package" 

dnf module enable nodejs:20 -y &>>$LOG_FILE
VALIDATE $? "enabling nodejs:20 package" 

dnf install nodejs -y &>>$LOG_FILE
VALIDATE $? "installing nodejs" 

mkdir -p /app 
# checking use exist or not
id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "adding application user" 
fi

curl -o /tmp/catalogue.zip https://roboshop-artifacts.s3.amazonaws.com/catalogue-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading application code" 

cd /app 
VALIDATE $? "changing directory to app"

rm -rf *
VALIDATE $? "removing existing files in app"

unzip /tmp/catalogue.zip &>>$LOG_FILE
VALIDATE $? "unzip applicaion code in /app"

npm install  &>>$LOG_FILE
VALIDATE $? "installing application dependencies"

cp $INITIAL_REPO/catalogue.service /etc/systemd/system/catalogue.service
VALIDATE $? "adding service file"

systemctl daemon-reload 
VALIDATE $? "daemon-reload"

systemctl enable catalogue 
VALIDATE $? "enabling catalogue" 

systemctl start catalogue
VALIDATE $? "starting catalogue"


cp $INITIAL_REPO/mongo.repo /etc/yum.repos.d/mongo.repo 
VALIDATE $? "setup mongoDB repo file" 

dnf install mongodb-org -y &>>$LOG_FILE
VALIDATE $? "installing mongoDB" 


mongosh --host mongodb.royalreddy.site </app/db/master-data.js &>>$LOG_FILE
VALIDATE $? "loading master date" 

# mongosh --host mongodb.royalreddy.site
# VALIDATE $? "connecting mongodb server" 

SHELL_END=$(date +%s)
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"