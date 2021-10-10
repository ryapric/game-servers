resource "aws_iam_instance_profile" "main" {
  name_prefix = "game-servers-"
  role        = aws_iam_role.main.name
}

resource "aws_iam_role" "main" {
  name_prefix = "game-servers-"
  path        = "/"

  assume_role_policy = <<-EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AllowInstanceProfile",
          "Effect": "Allow",
          "Action": "sts:AssumeRole",
          "Principal": {
            "Service": "ec2.amazonaws.com"
          }
        }
      ]
    }
  EOF

  inline_policy {
    name   = "GameServerBackupAccess"
    policy = <<-EOF
      {
        "Version": "2012-10-17",
        "Statement": [
          {
            "Sid": "AllowGameServerBackups",
            "Effect": "Allow",
            "Action": [
              "s3:Describe*",
              "s3:Get*",
              "s3:List*",
              "s3:Put*"
            ],
            "Resource": [
              "arn:aws:s3:::ryapric-game-servers-${data.aws_caller_identity.current.account_id}",
              "arn:aws:s3:::ryapric-game-servers-${data.aws_caller_identity.current.account_id}/*"
            ]
          }
        ]
      }
    EOF
  }
}
