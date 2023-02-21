#!/bin/bash -e
#
# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.
#

mkdir -p /tmp/upgrade

# Metadata information
instance_metadata=$(oci-metadata -j)
echo "$instance_metadata" > /tmp/upgrade/oci_metadata.json
compute_ocid=$(echo $instance_metadata | jq -r '.instance.id')
source_ocid=$compute_ocid
source_hostname=$(echo $instance_metadata | jq -r '.instance.metadata.source_hostname')
source_metadata=$(oci compute instance get --instance-id $compute_ocid --auth instance_principal)
echo "$source_metadata" > /tmp/upgrade/source_metadata.json

core_metadata=$(echo $source_metadata | jq -r '.data.metadata')
echo $core_metadata > /tmp/upgrade/core_metadata.json

extended_metadata=$(echo $source_metadata | jq -r '.data."extended-metadata"')
echo $extended_metadata > /tmp/upgrade/extended_metadata.json

is19cInstance=$(echo $source_metadata | jq -r '.data.metadata.admin_password_encrypted')
if [ "null" = "${is19cInstance}" ]; then
    echo "Source Instance is not compatible with metadata upgrade script."
    exit 1
else
  is19c56or60=$(echo $source_metadata | jq -r '.data.metadata.stack_version')
  if [ "null" = "${is19c56or60}" ]; then
    echo "Source Instance of 19c is compatible with metadata upgrade script."
  else
    echo "Source Instance of 19c is not currently compatible with metadata upgrade script."
    exit 2
  fi
fi

essbase_admin_password=$(echo $source_metadata | jq -r '.data.metadata.admin_password_encrypted')
database_admin_password=$(echo $source_metadata | jq -r '.data."extended-metadata".database.admin_password_encrypted')
idcs_client_secret=$(echo $source_metadata | jq -r '.data."extended-metadata".idcs.client_secret_encrypted')
security_mode=$(echo $source_metadata | jq -r '.data.metadata.security_mode')

kms_crypto_endpoint=$(echo $source_metadata | jq -r '.data.metadata.kms_crypto_endpoint')
kms_key_id=$(echo $source_metadata | jq -r '.data.metadata.kms_key_id')

#Compute KMS Management endpoint from KMS Crypto endpoint
kms_management_endpoint=${kms_crypto_endpoint/-crypto.kms./-management.kms.}
echo "Using KMS Management Endpoint $kms_management_endpoint ..."

ocid_vault=$(oci kms management key get --key-id $kms_key_id --auth instance_principal --endpoint $kms_management_endpoint --query 'data."vault-id"' --raw-output)
ocid_compartment=$(oci kms management vault get --vault-id  $ocid_vault --auth instance_principal --query 'data."compartment-id"' --raw-output)

#Create Essbase admin password secret
plaintext=$(oci kms crypto decrypt --auth instance_principal --ciphertext $essbase_admin_password --key-id $kms_key_id --endpoint $kms_crypto_endpoint --query 'data.plaintext' --raw-output)
ocid_essbase_password=$(oci vault secret create-base64 --auth instance_principal --compartment-id $ocid_compartment --secret-name essbase$RANDOM --vault-id $ocid_vault --key-id $kms_key_id --secret-content-content $plaintext --query 'data.id' --raw-output)
echo "Created Vault Secret for Essbase Admin password. $ocid_database_password"

#Create Database admin password secret
plaintext=$(oci kms crypto decrypt --auth instance_principal --ciphertext $database_admin_password --key-id $kms_key_id --endpoint $kms_crypto_endpoint --query 'data.plaintext' --raw-output)
ocid_database_password=$(oci vault secret create-base64 --auth instance_principal --compartment-id $ocid_compartment --secret-name db$RANDOM --vault-id $ocid_vault --key-id $kms_key_id --secret-content-content $plaintext --query 'data.id' --raw-output)
echo "Created Vault Secret for Database Admin password. $ocid_database_password"

#Create IDCS client secret
if [ "null" != "${idcs_client_secret}" ]; then
  plaintext=$(oci kms crypto decrypt --auth instance_principal --ciphertext $idcs_client_secret --key-id $kms_key_id --endpoint $kms_crypto_endpoint --query 'data.plaintext' --raw-output)
  ocid_idcs_client_secret=$(oci vault secret create-base64 --auth instance_principal --compartment-id $ocid_compartment --secret-name idcs$RANDOM --vault-id $ocid_vault --key-id $kms_key_id --secret-content-content $plaintext --query 'data.id' --raw-output)
  echo "Created Vault Secret for IDCS Client Secret. $ocid_idcs_client_secret"
fi

cat /tmp/upgrade/core_metadata.json | jq --arg essbase_password $ocid_essbase_password --arg identity_provider $security_mode '. += {"admin_password_id":$essbase_password,"stack_version":"19c","node_index": "1","identity_provider":$identity_provider}' > /tmp/upgrade/upgraded_core_metadata.json
cat /tmp/upgrade/extended_metadata.json | jq --arg database_password $ocid_database_password '.database += {"admin_password_id":$database_password}' > /tmp/upgrade/upgraded_extended_metadata.json

if [ "null" != "${idcs_client_secret}" ]; then
  cat /tmp/upgrade/upgraded_extended_metadata.json | jq --arg idcs_client_secret $ocid_idcs_client_secret '.idcs += {"client_secret_id":$idcs_client_secret}' > /tmp/upgrade/idcs.json
  mv -f /tmp/upgrade/idcs.json /tmp/upgrade/upgraded_extended_metadata.json
fi

echo "Updating instance metadata..."
suppress=$(oci compute instance update --instance-id $compute_ocid --metadata file:///tmp/upgrade/upgraded_core_metadata.json --extended-metadata file:///tmp/upgrade/upgraded_extended_metadata.json --auth instance_principal --force)

metadata_updated=$(oci-metadata -j | jq -r '.instance.metadata.admin_password_id')

until [ $ocid_essbase_password == "${metadata_updated}" ]; do
  echo "Waiting for metadata to be updated. $metadata_updated"
  sleep 5
  metadata_updated=$(oci-metadata -j | jq -r '.instance.metadata.admin_password_id')
done

echo "Metadata updated. $metadata_updated"

instance_metadata=$(oci-metadata -j)
echo "$instance_metadata" > /tmp/upgrade/upgraded_metadata.json



