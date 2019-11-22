## Copyright © 2019, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

// Random suffix to make things unique
resource "random_string" "instance_uuid" {
  length  = 8
  lower   = true
  upper   = false
  special = false
  number  = true
}

locals {
  generated_name_prefix          = format("essbase_%s", random_string.instance_uuid.result)
  generated_dns_label            = format("ess%s", random_string.instance_uuid.result)
  generated_rcu_schema_prefix    = format("ESS%s", upper(random_string.instance_uuid.result))
  generated_atp_db_name          = format("ess%s", random_string.instance_uuid.result)
  generated_node_hostname_prefix = format("essbase%s", random_string.instance_uuid.result)

  use_existing_vcn = var.use_existing_vcn 
  use_existing_db  = var.use_existing_db 

  resource_name_prefix = var.service_name != "" ? var.service_name : local.generated_name_prefix
  rcu_schema_prefix    = var.rcu_schema_prefix != "" ? var.rcu_schema_prefix : local.generated_rcu_schema_prefix

  assign_public_ip = (var.assign_public_ip && var.use_existing_vcn) || (!var.use_existing_vcn && !var.create_private_subnet)

  create_load_balancer = var.create_load_balancer 

  enable_bastion = ! local.assign_public_ip
}

resource "tls_private_key" "stack_management_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "oci_kms_decrypted_data" "decrypted_db_admin_password" {
  count           = !local.use_existing_db && var.use_kms_provisioning_key ? 1 : 0
  ciphertext      = var.db_admin_password_encrypted
  crypto_endpoint = var.kms_crypto_endpoint
  key_id          = var.kms_key_id
}

data "oci_identity_compartment" "compartment" {
  id         = var.compartment_ocid
  depends_on = [null_resource.input_validation]
}

data "oci_identity_compartment" "vcn_compartment" {
  count = local.use_existing_vcn ? 1 : 0

  id         = var.existing_vcn_compartment_id
  depends_on = [null_resource.input_validation]
}

data "oci_identity_compartment" "db_compartment" {
  count = local.use_existing_db ? 1 : 0

  id         = var.existing_db_compartment_id
  depends_on = [null_resource.input_validation]
}

locals {
  target_vcn_compartment_id = local.use_existing_vcn ? join("", data.oci_identity_compartment.vcn_compartment.*.id) : data.oci_identity_compartment.compartment.id
  target_db_compartment_id  = local.use_existing_db ? join("", data.oci_identity_compartment.db_compartment.*.id) : data.oci_identity_compartment.compartment.id
}

module "demo-ca-cert" {
  source = "./modules/demo-ca-cert"
}

module "network" {
  source = "./modules/network"

  use_existing_vcn    = local.use_existing_vcn
  existing_vcn_id     = var.existing_vcn_id
  compartment_id      = local.target_vcn_compartment_id
  vcn_cidr            = var.vcn_cidr
  dns_label           = local.generated_dns_label
  display_name_prefix = local.resource_name_prefix
  enable_nat_gateway  = local.enable_bastion
}

module "application-subnet" {
  source = "./modules/application-subnet"

  use_existing_subnet   = local.use_existing_vcn
  existing_subnet_id    = var.existing_application_subnet_id
  compartment_id        = module.network.compartment_id
  vcn_id                = module.network.vcn_id
  cidr_block            = var.application_subnet_cidr
  dhcp_options_id       = module.network.default_dhcp_options_id
  route_table_id        = local.enable_bastion ? module.network.nat_route_table_id : module.network.internet_route_table_id
  create_private_subnet = var.create_private_subnet
  display_name_prefix   = local.resource_name_prefix
}

module "load-balancer-subnet" {
  source = "./modules/load-balancer-subnet"

  enabled             = local.create_load_balancer
  use_existing_subnet = local.use_existing_vcn
  existing_subnet_ids = compact(
    [
      var.existing_load_balancer_subnet_id,
      var.existing_load_balancer_subnet_id_2,
    ],
  )
  compartment_id      = module.network.compartment_id
  vcn_id              = module.network.vcn_id
  cidr_block          = var.load_balancer_subnet_cidr
  dhcp_options_id     = module.network.default_dhcp_options_id
  route_table_id      = module.network.internet_route_table_id
  display_name_prefix = local.resource_name_prefix
  enable_https        = var.enable_load_balancer_ssl
}

module "bastion-subnet" {
  source = "./modules/bastion-subnet"

  enabled             = local.enable_bastion 
  use_existing_subnet = local.use_existing_vcn
  existing_subnet_id  = var.existing_bastion_subnet_id
  compartment_id      = module.network.compartment_id
  vcn_id              = module.network.vcn_id
  cidr_block          = var.bastion_subnet_cidr
  dhcp_options_id     = module.network.default_dhcp_options_id
  route_table_id      = module.network.internet_route_table_id
  display_name_prefix = local.resource_name_prefix
}

module "bastion" {
  source = "./modules/bastion"

  enabled             = local.enable_bastion 
  compartment_id      = data.oci_identity_compartment.compartment.id
  region              = var.region
  availability_domain = var.instance_availability_domain
  subnet_id           = module.bastion-subnet.subnet_id
  ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.stack_management_key.public_key_openssh}"
  display_name_prefix = local.resource_name_prefix
  instance_shape      = var.bastion_instance_shape
}

module "database" {
  source = "./modules/database"

  use_existing_db   = local.use_existing_db
  existing_db_id    = var.existing_db_id
  vcn_id            = module.network.vcn_id
  compartment_id    = local.target_db_compartment_id
  db_name           = local.generated_atp_db_name
  db_admin_username = var.db_admin_username
  db_admin_password = var.use_kms_provisioning_key ? base64decode(
    join(
      "",
      data.oci_kms_decrypted_data.decrypted_db_admin_password.*.plaintext,
    ),
  ) : var.db_admin_password

  license_model       = var.db_license_model
  display_name_prefix = local.resource_name_prefix
}

module "database-backup-bucket" {
  source = "./modules/bucket"

  enabled        = !var.use_existing_db
  compartment_id = local.target_db_compartment_id

  # Bucket name needs to be unique
  bucket_name = "backup_${module.database.db_name}"
}

module "subscription" {
  source = "./modules/subscription"

  compartment_id              = data.oci_identity_compartment.compartment.id
  mp_listing_id               = var.mp_listing_id
  mp_listing_resource_version = var.mp_listing_resource_version
  mp_listing_resource_id      = var.mp_listing_resource_id
}

module "essbase" {
  source = "./modules/essbase"

  compartment_id      = data.oci_identity_compartment.compartment.id
  region              = var.region
  availability_domain = var.instance_availability_domain

  display_name_prefix = local.resource_name_prefix

  ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.stack_management_key.public_key_openssh}"
  ssh_private_key     = tls_private_key.stack_management_key.private_key_pem

  node_hostname_prefix = local.generated_node_hostname_prefix
  shape                = var.instance_shape
  subnet_id            = module.application-subnet.subnet_id
  assign_public_ip     = local.assign_public_ip
  bastion_host         = module.bastion.public_ip

  config_volume_size = var.config_volume_size
  data_volume_size   = var.data_volume_size
  rcu_schema_prefix  = local.rcu_schema_prefix

  admin_username = var.essbase_admin_username
  admin_password = var.use_kms_provisioning_key ? var.essbase_admin_password_encrypted : var.essbase_admin_password

  image_id = module.subscription.image_id

  use_kms_provisioning_key = var.use_kms_provisioning_key
  kms_key_id               = var.use_kms_provisioning_key ? var.kms_key_id : ""
  kms_crypto_endpoint      = var.use_kms_provisioning_key ? var.kms_crypto_endpoint : ""

  db_database_id    = module.database.database_id
  db_admin_username = var.db_admin_username
  db_admin_password = var.use_kms_provisioning_key ? var.db_admin_password_encrypted : var.db_admin_password
  db_connect_alias  = "${module.database.db_name}_low"

  db_backup_bucket_namespace = module.database-backup-bucket.bucket_namespace
  db_backup_bucket_name      = module.database-backup-bucket.bucket_name

  security_mode                = var.security_mode
  idcs_client_tenant           = var.security_mode == "idcs" ? var.idcs_client_tenant : ""
  idcs_client_id               = var.security_mode == "idcs" ? var.idcs_client_id : ""
  idcs_client_secret           = var.security_mode == "idcs" && var.use_kms_provisioning_key ? var.idcs_client_secret_encrypted : var.idcs_client_secret
  idcs_external_admin_username = var.security_mode == "idcs" ? var.idcs_external_admin_username : ""

  external_url = local.create_load_balancer ? module.load-balancer.external_url : ""

  demo_ca = module.demo-ca-cert
}

module "load-balancer" {
  source = "./modules/load-balancer"

  enabled             = local.create_load_balancer
  compartment_id      = data.oci_identity_compartment.compartment.id
  subnet_ids          = module.load-balancer-subnet.subnet_ids
  subnet_count        = module.load-balancer-subnet.subnet_count
  shape               = var.load_balancer_shape
  node_count          = 1
  node_ip_addresses   = [module.essbase.node_private_ip]
  display_name_prefix = local.resource_name_prefix

  enable_https = var.enable_load_balancer_ssl

  demo_ca = module.demo-ca-cert
}

