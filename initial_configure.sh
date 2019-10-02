#!/bin/bash

# Constants
declare -r PROXY_SERVER='http://hostname:PORT/'
declare -r NTP_SERVER='ntp.nict.jp'

declare -r DHCP_IP_LIFETIME='8h'
declare -r DOMAN_SEARCH_SERVER='dns.example.com'

# backup_file path_to_file
backup_file() {
  # Get absolute path (starts with /)
  declare -r FULLPATH_TO_FILE="$(readlink -f "$1")"
  declare -r FULLPATH_TO_DIRECTORY="$(dirname "${FULLPATH_TO_FILE}")"

  # Not to ends with /
  declare -r BACKUP_PREFIX='./__root__'

  mkdir -p "${BACKUP_PREFIX}${FULLPATH_TO_DIRECTORY}"
  cp -a "$1" "${BACKUP_PREFIX}${FULLPATH_TO_FILE}"
}

# touch_file path_to_file [--sudo]
touch_file() {
  # Get absolute path (starts with /)
  declare -r FULLPATH_TO_FILE="$(readlink -f "$1")"
  declare -r FULLPATH_TO_DIRECTORY="$(dirname "${FULLPATH_TO_FILE}")"

  declare -r CMD_OPT="$2"

  if [ -z "${CMD_OPT}" ]; then
    mkdir -p "${FULLPATH_TO_DIRECTORY}"
    touch "${FULLPATH_TO_FILE}"
  elif [ "${CMD_OPT}" = '--sudo' ]; then
    sudo mkdir -p "${FULLPATH_TO_DIRECTORY}"
    sudo touch "${FULLPATH_TO_FILE}"
  else
    printf 'ERROR: Invalid option: %s\n' "${CMD_OPT}"
  fi
}


# Setup proxy configuration
(
declare -r ENVIRONMENT_FILE='/etc/environment'
backup_file "${ENVIRONMENT_FILE}"

cat <<EOF | sudo tee -a "${ENVIRONMENT_FILE}"
export http_proxy=${PROXY_SERVER}
export https_proxy=${PROXY_SERVER}

EOF

declare -r APT_FILE='/etc/apt/apt.conf'

touch_file "${APT_FILE}" --sudo
backup_file "${APT_FILE}"

# Append proxy configuration
cat <<EOF | sudo tee -a /apt/apt.conf
Acquire::http::proxy "${PROXY_SERVER}";
Acquire::https::proxy "${PROXY_SERVER}";

EOF
)

# Configure NTP Server
(
declare -r TIMESYNC_FILE='/etc/systemd/timesyncd.conf'
backup_file "${TIMESYNC_FILE}"
sudo sed -i "s/^\(#\)\(NTP=\)/\2${NTP_SERVER}/" "${TIMESYNC_FILE}"
sudo systemctl daemon-reload
sudo systemctl restart systemd-timesyncd.service
)


sudo apt update

# Install DHCP server
sudo apt install dnsmasq

# Setup DHCP
(
declare -r DNS_MASQ_FILE='/etc/dnsmasq.conf'
sudo cat <<EOF | sudo tee -a "${DNS_MASQ_FILE}"
interface=eth0

dhcp-range=192.168.8.129,192.168.8.252,${DHCP_IP_LIFETIME}

# Optional
dhcp-option=option:router,192.168.8.124
dhcp-option=option:dns-server,192.168.8.124
dhcp-option=option:domain-search,${DOMAN_SEARCH_SERVER}

EOF

# Setup DNS cache server
sudo cat <<EOF | sudo tee -a "${DNS_MASQ_FILE}"
domain-needed
bogus-priv
expand-hosts
domain=denjo.local

EOF
)


# Wi-Fi Software Access Point
sudo apt install hostapd


# misc
sudo apt install vim
sudo update-alternatives --config editor
