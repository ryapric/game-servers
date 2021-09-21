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

data "template_file" "user_data" {
  template = <<-SCRIPT
    #!/usr/bin/env bash
    set -euo pipefail

    # Make a swapfile, just to be safe
    swapoff -a
    fallocate -l 2g /swap
    chmod 0600 /swap
    mkswap /swap
    swapon /swap

    # Install container runtime & build base game server image
    curl -fsSL https://get.docker.com | bash
    usermod -aG docker ubuntu

    git clone https://github.com/ryapric/game-servers.git /home/ubuntu/game-servers
    chown -R ubuntu:ubuntu /home/ubuntu
    
    docker build -t ryapric/game-servers:latest /home/ubuntu/game-servers

    # Grab backup data if not present
    apt-get update && apt-get install -y awscli
    account_id=$(aws sts get-caller-identity --query 'Account' --output text)
    if [[ ! -d /home/ubuntu/game-server-backups ]]; then
      aws s3 cp s3://game-server-backups-"$account_id"/backups.tar.gz /home/ubuntu/backups.tar.gz
      tar -C /home/ubuntu -xzf /home/ubuntu/backups.tar.gz
    fi

    # Set up backup script
    {
      echo "#!/usr/bin/env bash"
      echo "tar -C /home/ubuntu -czf backups.tar.gz /home/ubuntu/game-server-backups"
      echo "aws s3 cp /home/ubuntu/backups.tar.gz s3://game-server-backups-$account_id/backups.tar.gz"
    } > /usr/local/bin/backup_game_data.sh
    echo "0 * * * * root /bin/bash /usr/local/bin/backup_game_data.sh" > /etc/cron.d/backup_game_data
  SCRIPT
}
