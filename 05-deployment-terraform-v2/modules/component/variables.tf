variable "instance_type" {
  default = "t2.micro"
}

variable "common_tags" {
  default = {
    project   = "ecom"
    terraform = true
  }
}
variable "project" {
  default = "ecom"
}

variable "environment" {
  default = "dev"
}

variable "vpc_id" {
  
}

variable "component" {
}

variable "port" {
}

variable "priority" {
  
}

variable "ec2_tags" {
  default = {
    region  = "us-east-1"
    created = "devops"
  }
}

variable "zone_id" {
  default = "Z04344913L84I7UAM0FS4"
}

variable "domain" {
  default = "royalreddy.site"
}

# variable "security_group_id" {
#   type = list(string)
# }

variable "subnet_id" {
  
}

variable "vpc_zone_identifier"{
  type = list
}

variable "alb_listener_arn" {
  
}