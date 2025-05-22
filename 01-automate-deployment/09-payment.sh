#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Author: ROYAL 
# Date: 22-05-2025
# Version: v1
# Purpose: Automate payment-component configuration
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "scripted stated at::$Y $(date) $N"
USER_ID=$(id -u)
INITIAL_REPO=$PWD 
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

dnf install python3 gcc python3-devel -y &>>$LOG_FILE
VALIDATE $? "installing python3" 

# checking use exist or not
id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "adding application user" 
fi


curl -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading application code" 

cd /app 
VALIDATE $? "changing directory to app"

rm -rf *
VALIDATE $? "removing existing files in app"

unzip /tmp/payment.zip &>>$LOG_FILE
VALIDATE $? "unzip applicaion code in /app"


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
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"