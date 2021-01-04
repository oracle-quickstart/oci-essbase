## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
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

output "essbase_node_ids" {
  value = compact(module.essbase.nodes[*].id)
}

output "essbase_node_display_names" {
  value = compact(module.essbase.nodes[*].display_name)
}

output "essbase_node_public_ips" {
  value = compact(module.essbase.nodes[*].public_ip)
}

output "essbase_node_private_ips" {
  value = compact(module.essbase.nodes[*].private_ip)
}

output "essbase_url" {
  value = local.create_load_balancer ? join("", module.load-balancer.*.external_url) : module.essbase.external_url
}

output "essbase_external_url" {
  value = local.create_load_balancer ? join("", module.load-balancer.*.external_url) : module.essbase.external_url
}

output "essbase_redirect_url" {
  value = var.identity_provider == "idcs" ? (local.create_load_balancer ? format("%s/redirect_uri", join("", module.load-balancer.*.redirect_url_prefix)) : format("%s/redirect_uri", module.essbase.external_url)) : ""
}

output "essbase_post_logout_redirect_url" {
  value = var.identity_provider == "idcs" ? (local.create_load_balancer ? format("%s/jet/logout.html", join("", module.load-balancer.*.redirect_url_prefix)) : format("%s/jet/logout.html", module.essbase.external_url)) : ""
}

output "idcs_tenant" {
  value = var.identity_provider == "idcs" ? var.idcs_tenant : ""
}

output "idcs_client_id" {
  value = var.identity_provider == "idcs" ? var.idcs_client_id : ""
}

output "rcu_schema_prefix" {
  value = module.essbase.rcu_schema_prefix
}

output "bastion_host_id" {
  value = join("", module.bastion.*.id)
}

output "bastion_host_public_ip" {
  value = join("", module.bastion.*.public_ip)
}

output "z_messages" {
  value = "\n\n*********************\nOracle Essbase stack has been provisioned and is continuing configuration in the background.\nIt may take up to 20 minutes for configuration to complete.\n*********************\n"
}
