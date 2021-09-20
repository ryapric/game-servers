####################
# Backup S3 bucket #
####################
resource "aws_s3_bucket" "backups" {
  bucket = "game-server-backups-${data.aws_caller_identity.current.account_id}"
  acl    = "private"

  lifecycle_rule {
    id      = "Expire"
    enabled = true

    noncurrent_version_expiration {
      days = 14
    }
  }

  versioning {
    enabled = true
  }
}

####################
# Server Resources #
####################
resource "aws_instance" "main" {
  ami                    = data.aws_ami.latest.id
  instance_type          = var.instance_type
  key_name               = var.keypair_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.main.id]

  user_data = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail

    curl -fsSL https://get.docker.com | bash
    usermod -aG docker ubuntu

    git clone https://github.com/ryapric/game-servers.git /home/ubuntu/game-servers
    chown -R ubuntu:ubuntu /home/ubuntu
    
    docker build -t ryapric/game-servers:latest /home/ubuntu/game-servers
  SCRIPT

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    "Name" = "ryapric/game-servers"
  }
}

resource "aws_eip" "servers" {
  instance = aws_instance.main.id
  vpc      = true
}
