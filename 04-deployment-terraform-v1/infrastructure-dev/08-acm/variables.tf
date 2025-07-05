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

