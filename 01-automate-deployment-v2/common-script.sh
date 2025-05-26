#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Managed_By: ROYAL 
# Date: 21-05-2025
# Version: v1
# Purpose: common script all components
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

check_root(){
    if [ $USER_ID -ne 0 ]
    then
        echo -e "$R ERROR: need to provide sudo user access $N"
        exit 1
    fi
}

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

time_taken(){
    TOTEL=$(($1 -SHELL_START))
    echo -e "time taken for script execution: $Y $TOTEL seconds $N"
}

app_user(){
    mkdir -p /app 
    # checking use exist or not
    id roboshop &>>$LOG_FILE

    if [ $? -ne 0 ]
    then 
        useradd --system --home /app --shell /sbin/nologin --comment "roboshop system user" roboshop &>>$LOG_FILE
        VALIDATE $? "adding application user" 
    fi
}

nodejs_installation(){
    dnf module disable nodejs -y &>>$LOG_FILE
    VALIDATE $? "disabling default nodejs package" 

    dnf module enable nodejs:20 -y &>>$LOG_FILE
    VALIDATE $? "enabling nodejs:20 package" 

    dnf install nodejs -y &>>$LOG_FILE
    VALIDATE $? "installing nodejs" 
}

maven_installation(){
    dnf install maven -y &>>$LOG_FILE
    ALIDATE $? "installing maven"
}

python_installation(){
    dnf install python3 gcc python3-devel -y &>>$LOG_FILE
    VALIDATE $? "installing python3" 
}

golang_installation(){
    dnf install golang -y &>>$LOG_FILE
    VALIDATE $? "installing golang"
}

nginx_installation(){
    dnf module disable nginx -y &>>$LOG_FILE
    VALIDATE $? "disabling default nginx package" 

    dnf module enable nginx:1.24 -y &>>$LOG_FILE
    VALIDATE $? "enabling nginx:1.24 package" 

    dnf install nginx -y &>>$LOG_FILE
    VALIDATE $? "installing default nginx package" 
}

app_code_download(){
    curl -o /tmp/$1.zip https://roboshop-artifacts.s3.amazonaws.com/$1-v3.zip &>>$LOG_FILE
    VALIDATE $? "downloading application code" 

    cd /app 
    VALIDATE $? "changing directory to app"

    rm -rf *
    VALIDATE $? "removing existing files in app"

    unzip /tmp/$1.zip &>>$LOG_FILE
    VALIDATE $? "unzip applicaion code in /app"
}