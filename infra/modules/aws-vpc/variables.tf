variable "vpc_name" {
  description = "Name of the VPC"
}

variable "vpc_cidr" {
  description = "CIDR of the VPC"
}

variable "stage" {
  description = "Environment (Stage)"
}

variable "aws_vpc_azs" {
  type = list
  default = ["ap-southeast-2a", "ap-southeast-2b", "ap-southeast-2c"]
}

variable "app_name" {
  description = "The name of the app being deployed (used for Domains e.g. $stage.$app_name.tymlez.com)"
}

variable "cluster_name" {
  description = "cluster_name"
}