#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Author: ROYAL 
# Date: 22-05-2025
# Version: v1
# Purpose: Automate shipping-component configuration
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

echo "Please enter root password to setup"
read -s MYSQL_ROOT_PASSWORD

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

dnf install maven -y &>>$LOG_FILE
VALIDATE $? "installing maven"


# checking use exist or not
id roboshop &>>$LOG_FILE

if [ $? -ne 0 ]
then 
    useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
    VALIDATE $? "adding application user" 
fi

curl -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping-v3.zip &>>$LOG_FILE
VALIDATE $? "downloading application code" 

cd /app 
VALIDATE $? "changing directory to app"

rm -rf *
VALIDATE $? "removing existing files in app"

unzip /tmp/shipping.zip &>>$LOG_FILE
VALIDATE $? "unzip applicaion code in /app"

mvn clean package &>>$LOG_FILE
VALIDATE() $? "mavan build and package"

mv $INITIAL_REPO/target/shipping-1.0.jar shipping.jar &>>$LOG_FILE
VALIDATE() $? "renaming package"


systemctl daemon-reload
VALIDATE $? "daemon-reload"

systemctl enable shipping 
VALIDATE $? "enabling shipping" 

systemctl start shipping
VALIDATE $? "starting shipping"


dnf install mysql -y  &>>$LOG_FILE
VALIDATE $? "Install MySQL"


mysql -h mysql.daws84s.site -u root -p$MYSQL_ROOT_PASSWORD -e 'use cities' &>>$LOG_FILE
if [ $? -ne 0 ]
then
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/schema.sql &>>$LOG_FILE
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/app-user.sql  &>>$LOG_FILE
    mysql -h mysql.daws84s.site -uroot -p$MYSQL_ROOT_PASSWORD < /app/db/master-data.sql &>>$LOG_FILE
    VALIDATE $? "Loading master data into MySQL"
else
    echo -e "Data is already loaded into MySQL ... $Y SKIPPING $N"
fi


systemctl restart shipping &>>$LOG_FILE
VALIDATE $? "Restart shipping"

SHELL_END=$(date +%s)
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"