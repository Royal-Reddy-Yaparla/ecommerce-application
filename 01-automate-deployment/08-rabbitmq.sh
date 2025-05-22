#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Author: ROYAL 
# Date: 22-05-2025
# Version: v1
# Purpose: Automate rabbitmq configuration
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

echo "Please enter rabbitmq password to setup"
read -s RABBITMQ_PASSWD

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
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"