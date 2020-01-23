variable "aws_region" {
  default     = "us-east-1"
}

variable "ami_key_pair_name" {
  description = "Name you gave the key that you uploaded to AWS"
  type = string
}



variable "app_name" {
  type = string
  description = "Name of your django app for naming related infrastructure."
}

# data "aws_availability_zones" "available" {}

variable "azs" {
 type = "list"
 default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ec2_amis" {
  description = "Ubuntu Server 16.04 LTS (HVM)"
  type        = "map"

  default = {
    "us-east-1" = "ami-059eeca93cf09eebd"
    "us-east-2" = "ami-0782e9ee97725263d"
    "us-west-1" = "ami-0ad16744583f21877"
    "us-west-2" = "ami-0e32ec5bc225539f5"
  }
}

variable "public_subnets_cidr" {
  type = "list"
  default = ["10.0.0.0/24", "10.0.2.0/24", "10.0.4.0/24"]
}

variable "private_subnets_cidr" {
  type = "list"
  default = ["10.0.1.0/24", "10.0.3.0/24", "10.0.5.0/24"]
}
