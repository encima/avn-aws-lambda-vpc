variable "aiven_api_token" {
    type = string
}

variable "tag" {
    type = string
    default = "avn-vpc-tf"
}

variable "private_subnet_count" {
    type = number
    default = 2
}

variable "public_subnet_count" {
  type = number
  default = 2
}

variable "aws_region" {
    type = string
    default = "ap-southeast-1"
}

variable "avn_region" {
  type = string
  default = "aws-ap-southeast-1"
}