variable "project" {
  default = "ecom"
}

variable "environment" {
  default = "dev"
}

variable "bastion_sg_tags" {
  type    = map
  default = {}
}

# VPN
variable "vpn_ports" {
  type = list
  default = [22,443,1194,943]
}

# mongodb
variable "mongodb_ports" {
  type = list
  default = [22,27017]
}

# mysql
variable "mysql_ports" {
  type = list
  default = [22,3306]
}

# redis
variable "redis_ports" {
  type = list
  default = [22,6379]
}

variable "rabbitmq_ports" {
  type = list
  default = [22,5672]
}

variable "catalogue_ports" {
  type = list
  default = [22,8080]
}