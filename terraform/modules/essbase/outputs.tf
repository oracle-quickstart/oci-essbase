## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "node" {

  value = {
     id = oci_core_instance.essbase.id,
     display_name = oci_core_instance.essbase.display_name,
     public_ip = oci_core_instance.essbase.public_ip,
     private_ip = oci_core_instance.essbase.private_ip,
     listen_port = local.listen_port
  }

}

output "rcu_schema_prefix" {
  value = var.rcu_schema_prefix
}

output "external_url" {
  value = local.external_url
}

