variable "ami_id" {
  type    = string
  default = "ami-09c813fb71547fc4f"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
  validation {
    condition     = contains(["t2.micro", "t2.small", "t2.medium"], var.instance_type)
    error_message = "Instance_type must be among 't2.micro', 't2.small' or 't2.medium' as per project requirement"
  }
}

variable "security_group_ids" {
  type = list(string)
}

variable "subnet_id" {
  type    = string

}

variable "project" {
  type = string
}

variable "environment" {
  type = string
}

variable "component" {
  type = string
}

variable "ec2_tags" {
  type    = map(any)
  default = {}
}

variable "common_tags" {
  type = map 
  default = {}  
}