## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "stack_version" {
  value = var.stack_version
}

output "stack_id" {
  value = var.is_upgrade? module.upgrade[0].stack_id : local.instance_uuid
}

output "stack_display_name" {
  value = var.is_upgrade? module.upgrade[0].stack_resource_id : local.resource_name_prefix
}

output "essbase_node_ids" {
  value = var.is_upgrade? [module.upgrade[0].node_id]: compact(module.essbase[0].nodes[*].id)
}

output "essbase_node_display_names" {
  value = var.is_upgrade? [module.upgrade[0].display_name]:  compact(module.essbase[0].nodes[*].display_name)
}

output "essbase_node_public_ips" {
  value = var.is_upgrade? [module.upgrade[0].public_ip] :  compact(module.essbase[0].nodes[*].public_ip)
}

output "essbase_node_private_ips" {
  value = var.is_upgrade? [module.upgrade[0].private_ip]:  compact(module.essbase[0].nodes[*].private_ip)
}

output "private_endpoint_db" {
  value = var.create_secure_db ? join("", module.database.*.private_endpoint) : null
}   

output "essbase_node_domain_names" {
  value = var.is_upgrade? [module.upgrade[0].domain_name] :  compact(module.essbase[0].nodes[*].domain_name)
}

output "essbase_url" {
  value = var.is_upgrade? null: (local.create_load_balancer ? join("", module.load-balancer.*.external_url) : module.essbase[0].external_url)
}

output "essbase_external_url" {
  value = var.is_upgrade? null: (local.create_load_balancer ? join("", module.load-balancer.*.external_url) : module.essbase[0].external_url)
}

output "essbase_redirect_url" {
  value = var.is_upgrade? null: (var.identity_provider == "idcs" ? (local.create_load_balancer ? format("%s/redirect_uri", join("", module.load-balancer.*.redirect_url_prefix)) : format("%s/redirect_uri", module.essbase[0].external_url)) : "")
}

output "essbase_post_logout_redirect_url" {
  value = var.is_upgrade? null: (var.identity_provider == "idcs" ? (local.create_load_balancer ? format("%s/jet/logout.html", join("", module.load-balancer.*.redirect_url_prefix)) : format("%s/jet/logout.html", module.essbase[0].external_url)) : "")
}

output "idcs_tenant" {
  value = var.is_upgrade? null: ((var.identity_provider == "idcs" && !var.is_upgrade) ? var.idcs_tenant : "")
}

output "idcs_client_id" {
  value = var.is_upgrade? null: ((var.identity_provider == "idcs" && !var.is_upgrade)? var.idcs_client_id : "")
}

output "rcu_schema_prefix" {
  value = var.is_upgrade? module.upgrade[0].rcu_schema_prefix:  module.essbase[0].rcu_schema_prefix
}

output "backup_bucket_name" {
  value = var.is_upgrade? module.upgrade[0].backup_bucket_name:  module.backup-bucket[0].name
}

output "catalog_bucket_name" {
  value = (var.is_upgrade || (length(module.catalog-bucket) == 0)) ? null : module.catalog-bucket[0].name
}

output "metadata_bucket_name" {
  value = var.is_upgrade? module.upgrade[0].metadata_bucket_name:  module.metadata-bucket[0].name
}

output "z_messages" {
  value = "\n\n*********************\nOracle Essbase stack has been provisioned and is continuing configuration in the background.\nIt may take up to 20 minutes for configuration to complete.\nLog details can be found on the target nodes at /var/log/essbase-init.log.\n*********************\n"
}
