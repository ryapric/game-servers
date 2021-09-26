locals {
  n_subnets           = 1 # length(data.aws_availability_zones.available.names)
  use_private_subnets = var.use_private_subnets ? 1 : 0

  game_ports = [
    {
      name     = "Valheim"
      port     = 2456
      protocol = "tcp"
    },
    {
      name     = "Valheim"
      port     = 2456
      protocol = "udp"
    },
    {
      name     = "Valheim"
      port     = 2457
      protocol = "tcp"
    },
    {
      name     = "Valheim"
      port     = 2457
      protocol = "udp"
    },
    {
      name     = "Minecraft"
      port     = 19132
      protocol = "udp"
    }
  ]
}

variable "instance_type" {
  type    = string
  default = "t3a.medium"
}

variable "keypair_name" {
  type = string
}

variable "use_private_subnets" {
  description = "Whether to use private subnets. Private subnets will receive a NAT gateway, which costs extra, so this defaults to 'false'."
  type        = bool
  default     = false
}

variable "volume_size" {
  type    = number
  default = 20
}
