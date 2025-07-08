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

variable "role_name" {
  default = "Ecom-Mysql-Credential-Access"
}