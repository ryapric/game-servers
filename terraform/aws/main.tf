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
      days = 5
    }
  }

  versioning {
    enabled = true
  }
}

####################
# Server Resources #
####################
resource "aws_spot_instance_request" "main" {
  instance_interruption_behavior = "stop"
  spot_type                      = "persistent"
  wait_for_fulfillment           = true

  ami                    = data.aws_ami.latest.id
  iam_instance_profile   = aws_iam_instance_profile.main.id
  instance_type          = var.instance_type
  key_name               = var.keypair_name
  subnet_id              = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.main.id]

  # TODO: set up backup script
  user_data = data.template_file.user_data.rendered

  root_block_device {
    volume_size = var.volume_size
  }

  credit_specification {
    cpu_credits = "standard" # NOT unlimited, Spot Instances are more likely to be shut down if so
  }
}

resource "aws_eip" "main" {
  vpc = true
}

resource "aws_eip_association" "main" {
  allocation_id = aws_eip.main.id
  instance_id   = aws_spot_instance_request.main.spot_instance_id # this attribute is subject to change
}
