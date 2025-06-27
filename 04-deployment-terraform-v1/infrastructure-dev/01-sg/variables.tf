variable "bastion_sg_name" {
  default = "bastion"
}

variable "bastion_sg_description" {
  default = "allowing SSH,HTTP,HTTPS"
}

variable "project" {
  default = "ecom"
}

variable "environment" {
  default = "dev"
}

variable "vpc_id" {
  default = "vpc-03f342ee5becaa338"
}

variable "bastion_sg_tags" {
  type    = map
  default = {}
}

# backend-alb
variable "backend_alb_sg_name" {
  default = "backend_alb"
}

variable "backend_alb_description" {
  default = "allowing SSH"
}

# VPN
variable "vpn_sg_name" {
  default = "vpn"
}

variable "vpn_sg_description" {
  default = "allowing SSH HTTPS 1193 943"
}


variable "vpn_ports" {
  type = list
  default = [22,443,1194,943]
}