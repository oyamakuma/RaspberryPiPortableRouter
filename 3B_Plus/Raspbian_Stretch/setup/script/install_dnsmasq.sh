#!/bin/bash
set -u

source "$(readlink -f './share/index.conf')"

declare -r DHCP_IP_LIFETIME='8h'
declare -r DOMAIN_SEARCH_SERVER='dns.example.com'
declare -r DNS_MASQ_FILE='/etc/dnsmasq.conf'
declare -r HOST_NAME='denjo.local'


# Install DHCP server
sudo apt install dnsmasq

# Setup DHCP
sudo cat <<EOF | sudo tee -a "${DNS_MASQ_FILE}"
interface=eth0

dhcp-range=192.168.8.129,192.168.8.252,${DHCP_IP_LIFETIME}

# Optional
dhcp-option=option:router,192.168.8.124
dhcp-option=option:dns-server,192.168.8.124
dhcp-option=option:domain-search,${DOMAIN_SEARCH_SERVER}

EOF

# Setup DNS cache server
sudo cat <<EOF | sudo tee -a "${DNS_MASQ_FILE}"
domain-needed
bogus-priv
expand-hosts
domain=${HOST_NAME}

EOF
