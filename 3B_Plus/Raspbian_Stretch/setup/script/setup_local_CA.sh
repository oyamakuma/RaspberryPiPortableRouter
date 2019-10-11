#!/bin/bash
# ref: https://qiita.com/suin/items/37313aee4543c5d01285
# ref: https://www.server-world.info/query?os=Debian_9&p=httpd&f=8
set -u



# [Local Certification Authority]
declare -r LOCAL_CA_SECRET='local_ca_secret.key'
declare -r LOCAL_CA_CRETIFICATE='local_ca_cert.pem'
# 5 years
declare -r LOCAL_CA_EXPIRATION='1825'


# [Domain]
declare -r GENERATED_SECRET='apache_secret.key'
declare -r GENERATED_CSR='apache.csr'
declare -r HOSTNAME_EXT='apache.ext'

declare -r CONSTANT_IP_ADDR='192.168.11.13'
declare -r DOMAIN_CRT='apache.crt'
# 5 years
declare -r DOMAIN_EXPIRATION='1825'

# [Apache]
declare -r APACHE_SSL_CONF='/etc/apache2/site-available/default-ssl.conf'
declare -r APACHE_CERT_DIR='/etc/ssl/private'

# [Setup local Certification Authority]
openssl genrsa -aes256 -out "${LOCAL_CA_SECRET}" 2048
openssl req -x509 -new -nodes -key "${LOCAL_CA_SECRET}" -sha256 -days "${LOCAL_CA_EXPIRATION}" -out "${LOCAL_CA_CRETIFICATE}"
# In case secret key encrypt, exec w/o -nodes
# openssl req -x509 -new -key "${LOCAL_CA_SECRET}" -sha256 -days "${LOCAL_CA_EXPIRATION}" -out "${LOCAL_CA_CRETIFICATE}"



# [Generate secret key of local CA]
openssl genrsa -out "${GENERATED_SECRET}" 2048
# Create certificate request
openssl req -new -key "${GENERATED_SECRET}" -out "${GENERATED_CSR}"

# [Configure hostname]
cat <<EOF | tee -a "${HOSTNAME_EXT}"
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names

[alt_names]
DNS.1=localhost
DNS.2=raspberrypi.local
IP.1=127.0.0.1
IP.2="${CONSTANT_IP_ADDR}"

EOF


# [Issue certification]
openssl x509 -req -in "${GENERATED_CSR}" \
                  -CA "${LOCAL_CA_CRETIFICATE}" \
                  -CAkey "${LOCAL_CA_SECRET}" \
                  -CAcreateserial \
                  -out "${DOMAIN_CRT}" \
                  -days "${DOMAIN_EXPIRATION}" \
                  -sha256 \
                  -extfile "${HOSTNAME_EXT}"
# [Optional]
# Disable Encryption
# openssl rsa -in $server.key -out $server.key

sudo a2enmod ssl
sudo a2ensite default-ssl

# [Apache SSL configure]
sudo mkdir -p "${APACHE_CERT_DIR}"

sudo cp "${GENERATED_CSR}" "${APACHE_CERT_DIR}/${GENERATED_CSR}"
sudo cp "${GENERATED_SECRET}" "${APACHE_CERT_DIR}/${GENERATED_SECRET}"
sudo cp "${LOCAL_CA_CRETIFICATE}" "${APACHE_CERT_DIR}/ca-bundle.crt"

sed -i "s|SSLCertificateFile .*|SSLCertificateFile ${APACHE_CERT_DIR}/${GENERATED_CSR}|" \
    -i "s|SSLCertificateKeyFile .*|SSLCertificateKeyFile ${APACHE_CERT_DIR}/${GENERATED_SECRET}|" \
    -i "s|SSLCACertificateFile .*|${APACHE_CERT_DIR}/ca-bundle.crt|" "${APACHE_SSL_CONF}"

sudo systemctl restart apache2.service
