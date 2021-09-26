#!/usr/bin/env bash
set -euo pipefail

# TODO: get all this into Aether instead

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
if [[ ! -d /home/ubuntu/game-data ]]; then
  aws s3 cp s3://ryapric-game-servers-"${account_id}"/backups.tar.gz /home/ubuntu/backups.tar.gz
  tar -v -C /home/ubuntu -xzf /home/ubuntu/backups.tar.gz
fi

# Set up backup script
cat <<EOF > /usr/local/bin/backup_game_data
#!/usr/bin/env bash
cd /home/ubuntu
tar -czf backups.tar.gz ./game-data
aws s3 cp ./backups.tar.gz s3://ryapric-game-servers-${account_id}/backups.tar.gz
EOF
chmod +x /usr/local/bin/backup_game_data
echo '0 * * * * root /bin/bash /usr/local/bin/backup_game_data > /home/ubuntu/cron.log 2>&1' > /etc/cron.d/backup_game_data

# Also run a backup at server shutdown
cat <<EOF > /etc/systemd/system/backup_game_data_on_shutdown.service
[Unit]
Description=Run backup at shutdown
Requires=network.target
DefaultDependencies=no
Before=shutdown.target reboot.target

[Service]
Type=oneshot
RemainAfterExit=true
ExecStart=/bin/true
ExecStop=/bin/bash /usr/local/bin/backup_game_data

[Install]
WantedBy=multi-user.target
systemctl daemon-reload
systemctl enable backup_game_data_on_shutdown.service
systemctl start backup_game_data_on_shutdown.service
EOF
