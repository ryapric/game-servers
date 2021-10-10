# ####################
# # Backup S3 bucket #
# ####################
# # This was removed from state tracking via `terraform state rm`, so the other resources could be destroyed;
# # best to deploy this separately in the future, BUT it will need to exist for the IAM Role to succeed
# resource "aws_s3_bucket" "main" {
#   bucket = "ryapric-game-servers-${data.aws_caller_identity.current.account_id}"
#   acl    = "private"

#   lifecycle_rule {
#     id      = "Expire"
#     enabled = true

#     noncurrent_version_expiration {
#       days = 3
#     }
#   }

#   versioning {
#     enabled = true
#   }
# }

####################
# Server Resources #
####################
# module "game_server" {
#   source = "https://github.com/opensourcecorp/gaia//providers/aws/ec2_instance"


# }

resource "aws_spot_instance_request" "main" {
  instance_interruption_behavior = "stop"
  spot_type                      = "persistent"
  wait_for_fulfillment           = true

  ami                    = data.aws_ami.latest.id
  iam_instance_profile   = aws_iam_instance_profile.main.name
  instance_type          = var.instance_type
  key_name               = var.keypair_name
  subnet_id              = aws_subnet.public[0].id
  user_data              = file("./user_data.sh")
  vpc_security_group_ids = [aws_security_group.main.id]

  credit_specification {
    cpu_credits = "standard"
  }

  root_block_device {
    volume_size = var.volume_size
  }

  tags = {
    Name = "ryapric/game-servers"
  }

  # Need this to apply tags to actual instances, since this resource can't do that itself
  provisioner "local-exec" {
    command = "aws ec2 create-tags --resources ${self.spot_instance_id} --tags Key=Name,Value=ryapric/game-servers Key=spot-req-id,Value=${self.id}"
  }
}

resource "aws_eip" "main" {
  vpc = true
}

resource "aws_eip_association" "main" {
  allocation_id = aws_eip.main.id
  instance_id   = aws_spot_instance_request.main.spot_instance_id
}
