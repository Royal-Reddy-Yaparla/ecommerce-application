# create ec2 mongodb


# using terraform null resource ansible integration 

/* null resouces won't create any resource, but 
it will follow stardard life-cycle of terraform ,
we can null resourcs for connect instances 
NOTE: terraform null-resource is deprecated , instead , we can use terraform data
*/

/* 
1. connect instance
2. copy the scripts 
3. excute script
*/






/*
to integrate terraform with ansible , we will install ansible in a server 
by using ansible pull , locally do configuration , this process helps 
create master and later connect nodes etc.

Ansible pull helps to 
clone the ansible code 

write a script for install and ansible pull
*/