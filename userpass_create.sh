#!/bin/sh
set -o xtrace

docker exec -it vault sh -c '

export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=root

export VAULT_USER="Kamelia"
export VAULT_PASSWORD="Aityahia"


#enable userpass to create an authentication method for creating and managing the certificates
vault auth enable userpass

#create a new username and password with the policy we created earlier
vault write auth/userpass/users/${VAULT_USER} \
    password=${VAULT_PASSWORD} \
    token_policies="pki_int_policy"

#vault auth disable userpass

'