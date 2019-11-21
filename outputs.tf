/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

output "essbase_node_id" {
  value = "${module.essbase.node_id}"
}

output "essbase_node_public_ip" {
  value = "${module.essbase.node_public_ip}"
}

output "essbase_node_private_ip" {
  value = "${module.essbase.node_private_ip}"
}

output "essbase_node_domain_name" {
  value = "${module.essbase.node_domain_name}"
}

output "essbase_url" {
  value = "${module.essbase.external_url}"
}

output "rcu_schema_prefix" {
  value = "${module.essbase.rcu_schema_prefix}"
}

output "bastion_host_public_ip" {
  value = "${module.bastion.public_ip}"
}
