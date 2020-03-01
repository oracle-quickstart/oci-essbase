## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "essbase_node_id" {
  value = module.essbase.node_id
}

output "essbase_node_public_ip" {
  value = module.essbase.node_public_ip
}

output "essbase_node_private_ip" {
  value = module.essbase.node_private_ip
}

output "essbase_node_domain_name" {
  value = module.essbase.node_domain_name
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

output "idcs_client_tenant" {
  value = var.security_mode == "idcs" ? var.idcs_client_tenant : ""
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

