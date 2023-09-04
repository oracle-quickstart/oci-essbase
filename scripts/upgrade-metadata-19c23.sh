#!/bin/bash -e
#
# Copyright (c) 2023 Oracle and/or its affiliates.
# Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.
#

upgrade_ws=${UPGRADE_WS:-/tmp/upgrade}
upgrade_debug=${UPGRADE_DEBUG:-false}

if [ ! -f /etc/essbase/instance.conf ]; then
  echo "Source Instance not compatible with this update script."
  exit 2
fi

mkdir -p $upgrade_ws

/u01/tools/bin/pyhocon -i /etc/essbase/instance.conf -o $upgrade_ws/instance.conf.json -f json
cat $upgrade_ws/instance.conf.json | jq -r . > $upgrade_ws/conf.json
sed -i 's/{KMS}//g' $upgrade_ws/conf.json

# Metadata information
instance_metadata=$(oci-metadata -j)
echo "$instance_metadata" > $upgrade_ws/oci_metadata.json
cat $upgrade_ws/oci_metadata.json | jq -r '.instance.metadata' > $upgrade_ws/oci_instance_metadata.json

compute_ocid=$(echo $instance_metadata | jq -r '.instance.id')
source_ocid=$compute_ocid
source_hostname=$(echo $instance_metadata | jq -r '.instance.metadata.source_hostname')
source_metadata=$(oci compute instance get --instance-id $compute_ocid --auth instance_principal)
echo "$source_metadata" > $upgrade_ws/source_metadata.json

core_metadata=$(echo $source_metadata | jq -r '.data.metadata')
echo $core_metadata > $upgrade_ws/source_core_metadata.json

extended_metadata=$(echo $source_metadata | jq -r '.data."extended-metadata"')
echo $extended_metadata > $upgrade_ws/source_extended_metadata.json

is19c23Instance=$(echo $core_metadata | jq -r '.metadata_bucket_name')
if [ "null" = "${is19c23Instance}" ]; then
  echo "Source Instance is not 19c2.3 and not compatible with this update script."
  exit 3
fi

# Join /etc/essbase/instance.conf and OCI instance metadata
# Because info from old metadata and old extended-metadata are needed for the metadata and extended (new)
jq -r -s ".[0] * .[1]" $upgrade_ws/conf.json $upgrade_ws/oci_instance_metadata.json > $upgrade_ws/conf_metadata.json

cat $upgrade_ws/conf_metadata.json | jq '.admin_password_encrypted=.system.adminPassword | 
 .admin_username=.system.adminUsername |
 .enable_embedded_proxy="true" | 
 .enable_monitoring= "false" |
 .external_admin_username=.security.idcs.externalAdminUsername| 
 .kms_crypto_endpoint=.kms.cryptoEndpoint | 
 .kms_key_id=.kms.keyId | 
 .notification_topic_id="" | 
 .rcu_schema_prefix=.database.schemaPrefix |
 .security_mode=.security.type | 
 .stack_display_name="essbase_"+.database.schemaPrefix | 
 .stack_id= .database.schemaPrefix | 
 del(.system, .kms, .database, .security, .idcs, .volume_ocids) ' > $upgrade_ws/core_metadata.json

cat $upgrade_ws/conf_metadata.json | jq -r '.db.admin_username=.database.adminUsername | 
.db.admin_password_encrypted=.database.adminPassword | 
.db.alias_name=.database.alias | 
.db.id=.database.databaseId | 
.db.connect_string=""| 
.db.type=.database.type| 
.db.backup_bucket.name=.database.backupBucketName | 
.db.backup_bucket."namespace"=.database.backupBucketNamespace | 
.metadata_bucket.id= .metadata_bucket_id | 
.metadata_bucket.name= .metadata_bucket_name | 
.metadata_bucket."namespace"= .metadata_bucket_ns | 
.iam.client_id=.security.idcs.clientId| 
.iam.client_secret_encrypted=.security.idcs.clientSecret| 
.iam.tenant=.security.idcs.clientTenant| 
.volumes.config.id=.volume_ocids[0] | 
.volumes.config.display_name="config" | 
.volumes.config.path="/u01/config" | 
.volumes.data.id=.volume_ocids[1]| 
.volumes.data.display_name="data"| 
.volumes.data.path="/u01/data"| 
.volumes.temp.id=null| 
.volumes.temp.display_name="temp"| 
.volumes.temp.path="/u01/tmp"| 
del(.system, .kms, .database, .security, .idcs, .metadata_bucket_name, .metadata_bucket_ns, .user_data, .kms_key_ocid, .ssh_authorized_keys,.metadata_bucket_id,.volume_group_ocid)| 
.database=.db| 
.idcs=.iam| 
del(.iam,.db) ' > $upgrade_ws/extended_metadata.json

essbase_admin_password=$(cat $upgrade_ws/conf.json | jq -r '.system.adminPassword')
database_admin_password=$(cat $upgrade_ws/conf.json | jq -r '.database.adminPassword')
idcs_client_secret=$(cat $upgrade_ws/conf.json | jq -r '.security.idcs.clientSecret')

security_mode=$(cat $upgrade_ws/conf.json | jq -r '.security.type')

kms_crypto_endpoint=$(cat $upgrade_ws/instance.conf.json| jq -r '.kms.cryptoEndpoint')
kms_key_id=$(cat $upgrade_ws/instance.conf.json | jq -r '.kms.keyId')

#Compute KMS Management endpoint from KMS Crypto endpoint
kms_management_endpoint=${kms_crypto_endpoint/-crypto.kms./-management.kms.}
echo "Using KMS Management Endpoint $kms_management_endpoint ..."

ocid_vault=$(oci kms management key get --key-id $kms_key_id --auth instance_principal --endpoint $kms_management_endpoint --query 'data."vault-id"' --raw-output)
ocid_compartment=$(oci kms management vault get --vault-id  $ocid_vault --auth instance_principal --query 'data."compartment-id"' --raw-output)

#Create Essbase admin password secret
plaintext=$(oci kms crypto decrypt --auth instance_principal --ciphertext $essbase_admin_password --key-id $kms_key_id --endpoint $kms_crypto_endpoint --query 'data.plaintext' --raw-output)
ocid_essbase_password=$(oci vault secret create-base64 --auth instance_principal --compartment-id $ocid_compartment --secret-name essbase$RANDOM --vault-id $ocid_vault --key-id $kms_key_id --secret-content-content $plaintext --query 'data.id' --raw-output)
echo "Created Vault Secret for Essbase Admin password. $ocid_essbase_password"

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

cat $upgrade_ws/core_metadata.json | jq --arg essbase_password $ocid_essbase_password --arg identity_provider $security_mode '. += {"admin_password_id":$essbase_password,"stack_version":"19c","node_index": "1","identity_provider":$identity_provider}' > $upgrade_ws/upgraded_core_metadata.json
cat $upgrade_ws/extended_metadata.json | jq --arg database_password $ocid_database_password '.database += {"admin_password_id":$database_password}' > $upgrade_ws/upgraded_extended_metadata.json

if [ "null" != "${idcs_client_secret}" ]; then
  cat $upgrade_ws/upgraded_extended_metadata.json | jq --arg idcs_client_secret $ocid_idcs_client_secret '.idcs += {"client_secret_id":$idcs_client_secret}' > $upgrade_ws/idcs.json
  mv -f $upgrade_ws/idcs.json $upgrade_ws/upgraded_extended_metadata.json
fi

if [ "false" != "${upgrade_debug}" ]; then
  echo "debug mode, exiting"
  exit 3
fi

echo "Updating instance metadata..."

suppress=$(oci compute instance update --instance-id $compute_ocid --metadata file://$upgrade_ws/upgraded_core_metadata.json --extended-metadata file://$upgrade_ws/upgraded_extended_metadata.json --auth instance_principal --force)

metadata_updated=$(oci-metadata -j | jq -r '.instance.metadata.admin_password_id')

until [ $ocid_essbase_password == "${metadata_updated}" ]; do
  echo "Waiting for metadata to be updated. $metadata_updated"
  sleep 5
  metadata_updated=$(oci-metadata -j | jq -r '.instance.metadata.admin_password_id')
done

echo "Metadata updated. $metadata_updated"

instance_metadata=$(oci-metadata -j)
echo "$instance_metadata" > $upgrade_ws/upgraded_metadata.json




