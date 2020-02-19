## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "vcn_id" {
  value = local.vcn_id
}

output "compartment_id" {
  value = local.compartment_id
}

output "default_dhcp_options_id" {
  value = local.use_existing_vcn ? join("", data.oci_core_vcn.vcn.*.default_dhcp_options_id) : join("", oci_core_vcn.vcn.*.default_dhcp_options_id)
}

output "internet_route_table_id" {
  value = join("", oci_core_route_table.igw.*.id)
}

output "nat_route_table_id" {
  value = join("", oci_core_route_table.nat.*.id)
}

