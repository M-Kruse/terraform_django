variable "rds_identifier" {
  default = "db"
}

variable "rds_instance_type" {
  default = "db.t2.micro"
}

variable "rds_storage_size" {
  default = "5"
}

variable "rds_engine" {
  default = "postgres"
}

variable "rds_engine_version" {
  default = "9.5.2"
}

variable "rds_db_name" {
  default = "rds_django_dev"
}

variable "rds_admin_user" {
  default = "rds_django"
}

variable "rds_admin_password" {
  description = "Password for the RDS database admin user"
}

variable "rds_publicly_accessible" {
  default = "false"
}
