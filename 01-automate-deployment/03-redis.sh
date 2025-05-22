#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Author: ROYAL 
# Date: 22-05-2025
# Version: v1
# Purpose: Automate redis configuration
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "scripted stated at::$Y $(date) $N"
USER_ID=$(id -u)

# logs setup
LOG_REPO="/var/log/ecommerce-app"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_REPO/$SCRIPT_NAME.log"

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


dnf module disable redis -y &>>$LOG_FILE
VALIDATE $? "disabling default redis package"


dnf module enable redis:7 -y &>>$LOG_FILE
VALIDATE $? "enabling redis:7 package" 

dnf install redis -y &>>$LOG_FILE
VALIDATE $? "installing redis" 


sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis/redis.conf &>>$LOG_FILE
VALIDATE $? "updating listen address"


systemctl enable redis 
VALIDATE $? "enabling redis" 

systemctl start redis 
VALIDATE $? "starting redis"


SHELL_END=$(date +%s)
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"