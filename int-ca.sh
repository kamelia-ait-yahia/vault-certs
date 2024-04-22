#!/bin/bash

set -euo pipefail

export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=root

# Répertoire local pour stocker les certificats
certs_dir="./certs/pki_int"
mkdir -p "$certs_dir"

echo -e "\n------------------ Disable pki secret engine for intermediate CA --------------------"
docker exec vault vault secrets disable pki_int || true
sleep 2

echo -e "\n------------------ Enable pki secret engine for intermediate CA --------------------"
docker exec vault vault secrets enable -path=pki_int pki

echo -e "\n------------------ Set default TTL for Intermediate CA to 5 years --------------------"
docker exec vault vault secrets tune -max-lease-ttl=43800h pki_int

echo -e "\n------------------ Create intermediate CA and save the CSR (Certificate Signing Request) --------------------"
# Exécuter la commande Vault pour générer le CSR à l'intérieur du conteneur
csr_response=$(docker exec vault vault write -format=json pki_int/intermediate/generate/internal \
        common_name="intermediate-ca.com" \
        issuer_name="Intermediate-CA" \
        | jq -r '.data.csr')

# Enregistrer le CSR dans un fichier local
echo "$csr_response" > "$certs_dir/pki_intermediate.csr"

echo -e "\n------------------ Send the intermediate CA's CSR to the root CA for signing --------------------"
# Exécuter la commande Vault pour signer le CSR à l'intérieur du conteneur
cert_response=$(docker exec vault vault write -format=json pki/root/sign-intermediate \
        issuer_ref="Root-CA" \
        csr="$csr_response" \
        format=pem_bundle ttl="43800h" \
        | jq -r '.data.certificate')

# Enregistrer le certificat signé dans un fichier local
echo "$cert_response" > "$certs_dir/intermediate.cert.crt"

echo -e "\n------------------ Publish the signed certificate back to the Intermediate CA --------------------"
# Utiliser le contenu du fichier local pour publier le certificat signé à l'intérieur du conteneur
docker exec vault sh -c "cat \"/certs/pki_int/intermediate.cert.crt\" | vault write pki_int/intermediate/set-signed certificate=-"

echo -e "\n------------------ Publish the intermediate CA URLs --------------------"
# Exécuter la commande Vault pour configurer les URLs de l'intermediate CA à l'intérieur du conteneur
docker exec vault vault write pki_int/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki_int/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki_int/crl"

echo "Certificat signé et autres données enregistrés dans $certs_dir"