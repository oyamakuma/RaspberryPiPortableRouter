#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

declare -r APT_FILE='/etc/apt/apt.conf'


touch_file "${APT_FILE}" --sudo
backup_file "${APT_FILE}"

cat <<EOF | sudo tee -a "${APT_FILE}"
Acquire::http::proxy "${PROXY_SERVER}";
Acquire::https::proxy "${PROXY_SERVER}";

EOF

sudo apt update
