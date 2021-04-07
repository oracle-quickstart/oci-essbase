## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "stack_version" {
  value = var.stack_version
}

output "stack_id" {
  value = local.stack_id
}

output "stack_display_name" {
  value = local.resource_name_prefix
}

output "essbase_node_id" {
  value = module.essbase.node.id
}

output "essbase_node_display_name" {
  value = module.essbase.node.display_name
}

output "essbase_node_public_ip" {
  value = module.essbase.node.public_ip
}

output "essbase_node_private_ip" {
  value = module.essbase.node.private_ip
}

output "essbase_url" {
  value = var.create_load_balancer ? module.load-balancer.external_url : module.essbase.external_url
}

output "essbase_external_url" {
  value = var.create_load_balancer ? module.load-balancer.external_url : module.essbase.external_url
}

output "essbase_redirect_url" {
  value = var.security_mode == "idcs" ? (var.create_load_balancer ? format("%s/redirect_uri", module.load-balancer.redirect_url_prefix) : format("%s/redirect_uri", module.essbase.external_url)) : ""
}

output "essbase_post_logout_redirect_url" {
  value = var.security_mode == "idcs" ? (var.create_load_balancer ? format("%s/jet/logout.html", module.load-balancer.redirect_url_prefix) : format("%s/jet/logout.html", module.essbase.external_url)) : ""
}

output "idcs_tenant" {
  value = var.security_mode == "idcs" ? var.idcs_tenant : ""
}

output "idcs_client_id" {
  value = var.security_mode == "idcs" ? var.idcs_client_id : ""
}

output "rcu_schema_prefix" {
  value = module.essbase.rcu_schema_prefix
}

output "bastion_host_id" {
  value = module.bastion.id
}

output "bastion_host_public_ip" {
  value = module.bastion.public_ip
}

output "z_messages" {
  value = "\n\n*********************\nOracle Essbase stack has been provisioned and is continuing configuration in the background.\nIt may take up to 20 minutes for configuration to complete.\n*********************\n"
}
