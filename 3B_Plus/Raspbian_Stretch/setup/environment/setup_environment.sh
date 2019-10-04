#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

source "$(readlink -f './environment.conf')"

# Setup proxy configuration
backup_file "${ENVIRONMENT_FILE}"

cat <<EOF | sudo tee -a "${ENVIRONMENT_FILE}"
export http_proxy=${PROXY_SERVER}
export https_proxy=${PROXY_SERVER}

EOF
