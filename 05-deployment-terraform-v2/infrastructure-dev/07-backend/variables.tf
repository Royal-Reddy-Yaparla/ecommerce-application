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

variable "component" {
  default = "catalogue"
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

variable "components" {
  type = list(object({
    name = string
    priority = number
  }))
  default = [ {
    name = "catalogue"
    priority = 10
  } ]

}