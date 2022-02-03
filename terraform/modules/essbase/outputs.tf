## Copyright (c) 2019, 2021, 2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "nodes" {
  value = local.nodes
}

output "rcu_schema_prefix" {
  value = var.rcu_schema_prefix
}

output "external_url" {
  value = local.external_url
}

