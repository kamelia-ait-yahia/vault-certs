#!/bin/sh
set -o xtrace

# Commands to execute inside the Docker container
docker exec -it vault sh -c '

# export VAULT_ADDR=http://vault:8200
# export VAULT_TOKEN=root

# export VAULT_ROLE_NAME="app-role"
# export VAULT_CERT_ALLOWED_DOMAIN="app.com"

# echo -e "\n------------------    Create a role to generate new certificates   --------------------"
# vault write pki_int/roles/$VAULT_ROLE_NAME \
#         allowed_domains="$VAULT_CERT_ALLOWED_DOMAIN" \
#         allow_subdomains=true \
#         max_ttl="8000h"


# echo -e "\n------------------    Read Role   --------------------"
# vault read pki_int/roles/$VAULT_ROLE_NAME

vault write pki_int/roles/app-role \
    allowed_domains="app.com" \
    allow_subdomains=true \
    allow_bare_domains=true \
    allow_ip_sans=false \
    allow_localhost=false \
    client_flag=false \
    country="FR" \
    locality="Paris" \
    street_address="Barbes" \
    enforce_hostnames=false \
    organization="Devoteam ORG" \
    ou="Devoteam OU" \
    postal_code="411045" \
    province="English, French" \
    require_cn=false \
    max_ttl="24h" \
    ttl="1h"

 vault read pki_int/roles/app-role


# Delete Role
# vault delete pki_int/roles/$VAULT_ROLE_NAME
'


