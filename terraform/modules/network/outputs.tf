## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "vcn_id" {
  value = "${data.oci_core_vcn.vcn.id}"
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
