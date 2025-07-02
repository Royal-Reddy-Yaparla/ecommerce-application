#/bin/bash

dnf install ansible -y
ansible-pull -U https://github.com/Royal-Reddy-Yaparla/ecom-ansible-roles.git -e component=$1 -e env=$2 main.yaml 