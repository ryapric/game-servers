#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

rm /etc/apt/sources.list

dpkg --add-architecture i386
{
  echo 'deb http://deb.debian.org/debian bullseye main contrib non-free'
  echo 'deb http://security.debian.org/debian-security bullseye-security main contrib non-free'
  echo 'deb http://deb.debian.org/debian bullseye-updates main contrib non-free'
} > /etc/apt/sources.list

apt-get update
apt-get install -y \
  curl \
  jq \
  lib32gcc-10-dev

curl -fsSL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar vxzf -

for game in $(jq -rc '.[]' "${HOME}"/games.json); do
  game_root=$(jq -rc '.game_root' <(echo "${game}"))
  app_id=$(jq -rc '.app_id' <(echo "${game}"))
  mkdir -p "${HOME}"/Steam/steamapps/common/"${game_root}"
  bash ./steamcmd.sh \
    +@sSteamCmdForcePlatformType linux \
    +login anonymous \
    +force_install_dir "${HOME}"/Steam/steamapps/common/"${game_root}" \
    +app_update "${app_id}" validate \
    +quit
done
