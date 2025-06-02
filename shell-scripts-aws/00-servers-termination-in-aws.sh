#!/bin/bash
SHELL_START=$(date +%s)

#############################################################################
# Managed_By: ROYAL 
# Date: 02-06
# Version: v1
# Purpose: Automate the process of destroy EC2 instances and Route53 records
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo -e "scripted stated at::$Y $(date) $N"
USER_ID=$(id -u)

# logs setup
LOG_REPO="/var/log/servers-provison"
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOG_FILE="$LOG_REPO/$SCRIPT_NAME.log"
# echo "$LOG_FILE"

AMI="ami-09c813fb71547fc4f"
SECURITY_GR_ID="sg-0c07dddd955fb376a"
SUBNET_ID="subnet-0b2ada4cfcc744c81"
INSTANCE_TYPE="t2.micro"
ZONE_ID="Z07146881RI4INQX613W7"
DOMAIN_NAME="royalreddy.site"
# INSTANCES=("cataloge")
INSTANCES=("frontend" "cataloge" "cart" "user" "shipping" "payment" "dispatch" "mongodb" "mysql" "redis" "rabbitmq")
INSTANCE=$1
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
        echo -e "$G $2 is Success $N"  | tee -a $LOG_FILE
    else
        echo -e "$R $2 is Failed $N"  | tee -a $LOG_FILE
        exit 1 
    fi    
}



for instance in $@
do
    export PATH=$PATH:/usr/local/bin:/usr/bin
    INSTANCE_ID=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$instance" \
    --query "Reservations[].Instances[].InstanceId" \
    --output text)

    if [ $instance != "frontend" ]
    then
        IP=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance" \
        --query "Reservations[].Instances[].PrivateIpAddress" \
        --output text)
    else 
        IP=$(aws ec2 describe-instances \
        --filters "Name=tag:Name,Values=$instance" \
        --query "Reservations[].Instances[].PublicIpAddress" \
        --output text)
    fi

    # Terminate EC2 instance
    aws ec2 terminate-instances --instance-ids $INSTANCE_ID

    # Wait for instance termination (optional but safer)
    aws ec2 wait instance-terminated --instance-ids $INSTANCE_ID

    # Delete the Route53 A record
    aws route53 change-resource-record-sets \
    --hosted-zone-id $ZONE_ID \
    --change-batch "{
        \"Comment\": \"Deleting record set for $instance\",
        \"Changes\": [{
        \"Action\": \"DELETE\",
        \"ResourceRecordSet\": {
            \"Name\": \"$instance.royalreddy.site.\",
            \"Type\": \"A\",
            \"TTL\": 60,
            \"ResourceRecords\": [{\"Value\": \"$IP\"}]
        }
        }]
    }" | tee -a $LOG_FILE
done



SHELL_END=$(date +%s)
TOTEL=$((SHELL_END-SHELL_START))
echo -e "time taken for script execution: $Y $TOTEL seconds $N"
