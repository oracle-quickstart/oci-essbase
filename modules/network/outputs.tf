/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */
output "vcn_id" {
  value = "${data.oci_core_vcn.vcn.id}"
}

output "compartment_id" {
  value = "${data.oci_core_vcn.vcn.compartment_id}"
}

output "default_dhcp_options_id" {
  value = "${data.oci_core_vcn.vcn.default_dhcp_options_id}"
}

output "internet_route_table_id" {
  value = "${join("", oci_core_route_table.igw.*.id)}"
}

output "nat_route_table_id" {
  value = "${join("", oci_core_route_table.nat.*.id)}"
}
