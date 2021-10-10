locals {
  backup_bucket_name = "${var.backup_bucket_name_prefix}-${data.aws_caller_identity.current.account_id}"

  game_ports = [
    {
      # Valheim
      port        = 2456
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      # Valheim
      port        = 2456
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      # Valheim
      port        = 2457
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      # Valheim
      port        = 2457
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    },
    {
      # Minecraft
      port        = 19132
      protocol    = "udp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "backup_bucket_name_prefix" {
  description = "The root prefix (with no trailing special characters) of the S3 bucket name used for game data backups (which is deployed separately for persistence)"
  type        = string
  default     = "ryapric-game-servers"
}

variable "keypair_name" {
  type = string
}
