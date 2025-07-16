we are automating provision and configuration by using terraform and ansible.
previously deployment in ec2 ,in component server files , was giving host ip and port , 
but in auto-scaling and application load balancer , 

between component communication through ALB so , in component's server files
update , ALB's url and port 80, 

have to make sure 
- in ansible component's service file , make sure proper port and host_url
- alb's security group 