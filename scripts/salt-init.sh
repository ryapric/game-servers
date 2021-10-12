#!/usr/bin/env bash
set -euo pipefail

# Salt Master should be running, so... stop it
systemctl disable salt-master
systemctl stop salt-master

# Salt Minion should already be installed, so give it a new ID & re-init
sed -i -E \
  -e 's/^id:.*$/id: ryapric-game-servers/' \
  -e 's/^master:.*$/master: 10.0.1.100/' \
  /etc/salt/minion
systemctl restart salt-minion

salt-call -l info state.apply
