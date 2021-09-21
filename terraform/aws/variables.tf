locals {
  n_subnets = 1 # length(data.aws_availability_zones.available.names)
}

variable "instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "keypair_name" {
  type = string
}

variable "volume_size" {
  type    = number
  default = 20
}
