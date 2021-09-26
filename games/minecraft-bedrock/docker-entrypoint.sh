#!/usr/bin/env bash
set -euo pipefail

world_name="${1}"

mkdir -p ./WORLDS/"${world_name}"
cd ./WORLDS/"${world_name}"

# Get defaults, refusing to overwrite custom stuff already here
find ../../ \
  -maxdepth 1 \
  -not -path '../../' \
  -not -path '../../WORLDS' \
  -exec cp -r -n {} . \;

export LD_LIBRARY_PATH=.
/usr/local/bin/bedrock_server
