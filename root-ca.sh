#!/bin/sh
set -o xtrace
export VAULT_ADDR=http://vault:8200
export VAULT_TOKEN=root

# Créer les répertoires nécessaires pour les certificats
rm -rf certs/
mkdir -p certs/pki_root
mkdir -p certs/pki_int
mkdir -p certs/server

# Désactiver le moteur secret PKI s'il est activé
docker exec -it vault vault secrets disable pki
sleep 2

# Activer le moteur secret PKI
docker exec -it vault vault secrets enable pki

# Configurer la durée de validité par défaut du CA à 10 ans
docker exec -it vault vault secrets tune -max-lease-ttl=87600h pki

# Générer le certificat CA racine
docker exec -it vault vault write -format=json pki/root/generate/internal \
     common_name="root-ca.com" \
     issuer_name="Root-CA" \
     ttl=87600h > certs/pki_root/pki-ca-root.json

# Extraire le certificat CA et le sauvegarder dans un fichier séparé
cat certs/pki_root/pki-ca-root.json | jq -r .data.certificate > certs/pki_root/ca.crt

# Configurer les URL pour le CA racine
docker exec -it vault vault write pki/config/urls \
     issuing_certificates="$VAULT_ADDR/v1/pki/ca" \
     crl_distribution_points="$VAULT_ADDR/v1/pki/crl"

# Lister les informations sur l'émetteur
docker exec -it vault vault list pki/issuers/
