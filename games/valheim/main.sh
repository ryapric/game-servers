#!/usr/bin/env bash
set -euo pipefail

game_root=$(jq -rc '.valheim.game_root' "${HOME}"/games.json)
cd "${HOME}"/Steam/steamapps/common/"${game_root}" || exit 1

server_cfg="${1}"

export LD_LIBRARY_PATH=./linux64:"${LD_LIBRARY_PATH:-}"
export SteamAppID=892970

server_name=$(awk '/server_name/ { print $2 }' "${HOME}/${server_cfg}")
world_name=$(awk '/world_name/ { print $2 }' "${HOME}/${server_cfg}")
password=$(awk '/password/ { print $2 }' "${HOME}/${server_cfg}")

echo "Starting Valheim server; PRESS CTRL-C to exit"
chmod +x ./valheim_server.x86_64
./valheim_server.x86_64 \
  -name "${server_name}" \
  -port 2456 \
  -nographics \
  -batchmode \
  -world "${world_name}" \
  -password "${password}" \
  -public 1
