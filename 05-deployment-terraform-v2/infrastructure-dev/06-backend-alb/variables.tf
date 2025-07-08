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

variable "alb_tags" {
  default = {}
}

variable "zone_id" {
  default = "Z04344913L84I7UAM0FS4"
}

variable "domain" {
  default = "royalreddy.site"
}
