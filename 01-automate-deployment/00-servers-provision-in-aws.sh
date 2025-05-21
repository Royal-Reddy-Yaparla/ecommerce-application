#!/bin/bash

#############################################################################
# Author: ROYAL 
# Date: 20-05
# Version: v1
# Purpose: Automate the process of creating EC2 instances and Route53 records
#############################################################################


R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

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


mkdir -p "$LOG_REPO"
VALIDATE $? "creating log repo"

export PATH=$PATH:/usr/local/bin:/usr/bin
INSTANCE_ID=$(aws ec2 run-instances \
  --image-id $AMI \
  --instance-type $INSTANCE_TYPE \
  --security-group-ids $SECURITY_GR_ID \
  --subnet-id $SUBNET_ID \
  --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test}]' \
  --query 'Instances[*].InstanceId' \
  --output text)

echo "$INSTANCE_ID"

PUBLIC_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PublicIpAddress' --output text)

echo "$PUBLIC_IP"

PRIVATE_IP=$(aws ec2 describe-instances --instance-ids $INSTANCE_ID --query 'Reservations[*].Instances[*].PrivateIpAddress' --output text)

echo "$PRIVATE_IP"


aws route53 change-resource-record-sets \
  --hosted-zone-id $ZONE_ID \
  --change-batch '
  {
    "Comment": "Create a new A record "
    ,"Changes": [{
    "Action"            : "UPSERT"
    ,"ResourceRecordSet": {
        "Name"          : "royalreddy.site"
        ,"Type"         : "A"
        ,"TTL"          : 1,
        ,"ResourceRecords": [{ 
                "Value"     : "'$PUBLIC_IP'"
        }]
    }
 }]
}
'
# INSTANCE_ID=$(aws ec2 run-instances --image-id $AMI --instance-type $INSTANCE_TYPE --security-group-ids $SECURITY_GR_ID --subnet-id $SUBNET_ID --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=test}]' --query 'Instances[*].InstanceId' --output text)

# echo "$INSTANCE_ID"
