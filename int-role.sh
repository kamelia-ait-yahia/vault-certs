#!/bin/sh
set -o xtrace

# Commands to execute inside the Docker container
docker exec -it vault sh -c '

# Set Vault environment variables
export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=root

# # Define variables for consumer role and certificate details
CONSUMER_ROLE_NAME="app-role"
VAULT_CERT_NAME="consumer.app.com"
VAULT_CERT_SAN1_NAME="consumer.app.com"
VAULT_CERT_SAN2_NAME="consumer.app.com"

echo -e "\n------------------    Read Consumer Role   --------------------"
vault read pki_int/roles/$CONSUMER_ROLE_NAME

echo -e "\n------------------    Request Consumer Certificates   --------------------"
vault write -format=json pki_int/issue/$CONSUMER_ROLE_NAME \
    common_name="$VAULT_CERT_NAME" \
    alt_names="$VAULT_CERT_SAN1_NAME,$VAULT_CERT_SAN2_NAME" \
    ttl="3h" > certs/server/$VAULT_CERT_NAME.json

echo -e "\n------------------    Extract Consumer Certificate, CA, and Private Key   --------------------"
cat certs/server/$VAULT_CERT_NAME.json | jq -r .data.certificate > certs/server/$VAULT_CERT_NAME.crt
cat certs/server/$VAULT_CERT_NAME.json | jq -r .data.issuing_ca >> certs/server/$VAULT_CERT_NAME.crt
cat certs/server/$VAULT_CERT_NAME.json | jq -r .data.private_key > certs/server/$VAULT_CERT_NAME.key


# vault write pki_int/roles/app-role \
#     allowed_domains="app.com" \
#     allow_subdomains=true \
#     allow_bare_domains=true \
#     allow_ip_sans=false \
#     allow_localhost=false \
#     client_flag=false \
#     country="FR" \
#     locality="Paris" \
#     street_address="Barbes" \
#     enforce_hostnames=false \
#     organization="Devoteam ORG" \
#     ou="Devoteam OU" \
#     postal_code="411045" \
#     province="English, French" \
#     require_cn=false \
#     max_ttl="24h" \
#     ttl="1h"

# vault read pki_int/roles/app-role
'


