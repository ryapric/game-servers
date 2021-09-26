app_name          = "ryapric-game-servers"
aether_address    = "10.0.10.100"
shell_provisioner = [
  "printf 'auto enp0s8\niface enp0s8 inet static\n  address 10.0.10.200\n  netmask 255.255.255.0\n' >> /etc/network/interfaces.d/packer",
  "ifup enp0s8",
  "curl -fsSL -o /tmp/bootstrap_salt.sh https://bootstrap.saltproject.io",
  "bash /tmp/bootstrap_salt.sh -P -x python3 -j '{\"id\": \"ryapric-game-servers\", \"master\": \"10.0.10.100\", \"autosign_grains\": [\"kernel\"]}'",
  # "sleep 3600",
  "salt-call -l info state.apply",
  "ifdown enp0s8",
  "rm /etc/network/interfaces.d/packer"
]
