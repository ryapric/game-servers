#!/usr/bin/env bash
set -euo pipefail

# Salt Minion should already be installed, so give it a new ID & re-init
sed -i -E 's/^id:.*$/id: ryapric-game-servers/' /etc/salt/minion
systemctl restart salt-minion

salt-call -l info state.apply
