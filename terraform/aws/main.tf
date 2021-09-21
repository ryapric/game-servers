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
      days = 3
    }
  }

  versioning {
    enabled = true
  }
}

####################
# Server Resources #
####################
resource "aws_eip" "main" {
  vpc = true
}

resource "aws_eip_association" "main" {
  allocation_id = aws_eip.main.id
  instance_id   = aws_instance.main.id
}

resource "aws_instance" "main" {
  launch_template {
    id      = aws_launch_template.main.id
    version = aws_launch_template.main.latest_version
  }

  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.main.id]
}

resource "aws_launch_template" "main" {
  image_id      = data.aws_ami.latest.id
  instance_type = var.instance_type
  key_name      = var.keypair_name

  user_data = base64encode(data.template_file.user_data.rendered)

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size = var.volume_size
    }
  }

  # NOT unlimited, Spot Instances are more likely to be shut down if so.
  # However, this doesn't seem to take right now -- the instance still creates
  # itself using unlimited credit spec, so you might need to manually change it
  credit_specification {
    cpu_credits = "standard"
  }

  iam_instance_profile {
    arn = aws_iam_instance_profile.main.arn
  }

  instance_market_options {
    market_type = "spot"

    spot_options {
      instance_interruption_behavior = "stop"
      spot_instance_type             = "persistent"
    }
  }

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "ryapric/game-servers"
    }
  }
}
