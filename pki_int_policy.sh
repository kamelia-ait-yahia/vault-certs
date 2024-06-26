#!/bin/sh
set -o xtrace

docker exec -it vault sh -c '

export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=root


echo -e "\n------------------    List all existing policies   --------------------"
vault policy list

echo -e "\n------------------    Create a new policy to create update revoke and list certificates    --------------------"
vault policy write pki_int_policy ./certs/pki_int_policy.hcl

echo -e "\n------------------    Read Policy   --------------------"
vault policy read pki_int_policy

#echo -e "\n------------------    Delete Policy   --------------------"
#vault policy delete pki_int_policy

'