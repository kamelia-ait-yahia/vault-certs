#!/bin/sh
set -o xtrace

# Commands to execute inside the Docker container
export VAULT_CERT_NAME="consumer.app.com"
docker exec -it vault sh -c '

# Set Vault environment variables
export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=root

export VAULT_ROLE_NAME="app-role"
export VAULT_CERT_NAME="consumer.app.com"
export VAULT_CERT_SAN1_NAME="consumer2.app.com"
export VAULT_CERT_SAN2_NAME="consumer3.app.com"


#set roleid and secretid as env variables from the previous step
export VAULT_USER="Kamelia"
export VAULT_PASSWORD="Aityahia"

vault login -format=json -method=userpass \
    username=${VAULT_USER} \
    password=${VAULT_PASSWORD} | jq -r .auth.client_token > user.token

#store the token as env variable, now this token can be used to authenticate against Vault
export VAULT_TOKEN=`cat user.token`


echo -e "\n------------------    Read Role   --------------------"
vault read pki_int/roles/$VAULT_ROLE_NAME


echo -e "\n------------------    Request Certificates   --------------------"
vault write -format=json pki_int/issue/$VAULT_ROLE_NAME \
    common_name="$VAULT_CERT_NAME" \
    alt_names="$VAULT_CERT_SAN1_NAME,$VAULT_CERT_SAN2_NAME" \
    ttl="3h" > certs/server/$VAULT_CERT_NAME.json
'
echo -e "\n------------------    extract the certificate, issuing ca in the pem file and private key in the key file seperately   --------------------"
cat certs/server/$VAULT_CERT_NAME.json | jq -r .data.certificate > certs/server/$VAULT_CERT_NAME.crt
cat certs/server/$VAULT_CERT_NAME.json | jq -r .data.issuing_ca >> certs/server/$VAULT_CERT_NAME.crt
cat certs/server/$VAULT_CERT_NAME.json | jq -r .data.private_key > certs/server/$VAULT_CERT_NAME.key