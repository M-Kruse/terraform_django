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

variable "azs" {
 type = "list"
 default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "ec2_amis" {
  description = "Ubuntu Server 16.04 LTS (HVM)"
  type        = "map"

  default = {
    "us-east-1" = "ami-04763b3055de4860b"
    "us-east-2" = "ami-0fb0129cd568fe35f"
    "us-west-1" = "ami-0dd655843c87b6930"
    "us-west-2" = "ami-06d51e91cea0dac8d"
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
