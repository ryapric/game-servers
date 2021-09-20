locals {
  n_subnets = 1 # length(data.aws_availability_zones.available.names)
}

variable "instance_type" {
  type    = string
  default = "t3a.small"
}

variable "keypair_name" {
  type = string
}

variable "volume_size" {
  type    = number
  default = 20
}

data "aws_availability_zones" "available" {}

data "aws_caller_identity" "current" {}

data "aws_ami" "latest" {
  most_recent = true
  owners      = ["099720109477"] # ["136693071363"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"] # ["debian-11-amd64-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "http" "my_ip" {
  url = "https://ipv4.icanhazip.com"
}