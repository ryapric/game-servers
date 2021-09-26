#!/usr/bin/env bash
set -euo pipefail

world_name="${1}"

docker run \
  -dit \
  -p 19132/udp \
  -v "${HOME}"/game-data/minecraft:/root/minecraft/WORLDS \
  --restart always \
  --name minecraft_"${world_name}" \
  ryapric/minecraft:latest "${world_name}"
