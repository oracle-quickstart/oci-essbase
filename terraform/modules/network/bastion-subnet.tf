## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_security_list" "bastion" {
  count          = var.create_bastion_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "bastion"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  ingress_security_rules {
    // Allow inbound ssh traffic...
    protocol    = 6 // tcp
    source      = local.all_cidr
    stateless   = false
    description = "Allow inbound traffic for SSH"

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    // allow inbound icmp traffic of a specific type
    protocol    = 1
    source      = local.all_cidr
    stateless   = false
    description = "Allow inbound traffic for ICMP"

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    // Allow all outbound traffic
    destination      = local.all_cidr
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }

}

resource "oci_core_subnet" "bastion" {
  count          = var.create_bastion_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "bastion"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  cidr_block        = var.bastion_subnet_cidr_block
  security_list_ids = oci_core_security_list.bastion.*.id
  dns_label         = "bastion"

  route_table_id    = join("", oci_core_route_table.internet_route_table.*.id)
}

