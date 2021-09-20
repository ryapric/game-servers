#!/usr/bin/env bash
set -euo pipefail

world_name="${1}"
server_cfg="${world_name}_server.cfg"

docker run \
  -dit \
  -p 2456-2457:2456-2457/tcp \
  -p 2456-2457:2456-2457/udp \
  -v "${HOME}"/game-server-backups/valheim/"${world_name}":/root/.config/unity3d/IronGate/Valheim \
  --restart unless-stopped \
  --name valheim_"${world_name}" \
  ryapric/valheim:latest "${server_cfg}"
