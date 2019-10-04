#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

sudo apt install snapd

# Or sudo systemctl edit snapd.service
cat <<EOF | sudo tee -a "${SNAPD_SERVICE_OVERRIDE}"
[Service]
Environment=http_proxy=${PROXY_SERVER}
Environment=https_proxy=${PROXY_SERVER}

EOF

sudo systemctl daemon-reload
sudo systemctl restart snapd.service
