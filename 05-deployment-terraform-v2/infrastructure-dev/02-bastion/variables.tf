variable "instance_type" {
  default = "t2.micro" # for validation test try t2.large
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

variable "component" {
  default = "bastion"
}

variable "ec2_tags" {
  default = {
    region  = "us-east-1"
    created = "devops"
  }
}

