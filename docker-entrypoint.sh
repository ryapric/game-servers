#!/usr/bin/env bash

game="${1}"
game_root=$(jq -rc --arg '.[$game].game_root' "${HOME}"/games.json)

bash "${HOME}/games/${game}/main.sh" "${game_root}"
