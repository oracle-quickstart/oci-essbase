## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  all_cidr            = "0.0.0.0/0"
  enabled_count       = var.enabled ? 1 : 0
  use_existing_subnet = var.existing_subnet_id != ""
}

resource "oci_core_security_list" "bastion" {
  count          = local.use_existing_subnet ? 0 : local.enabled_count
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.display_name_prefix}-bastion"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  ingress_security_rules {
    // Allow inbound ssh traffic...
    protocol  = "6" // tcp
    source    = local.all_cidr
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    // allow inbound icmp traffic of a specific type
    protocol  = 1
    source    = local.all_cidr
    stateless = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    // Allow all outbound traffic
    destination      = var.target_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

resource "oci_core_subnet" "bastion" {
  count          = local.use_existing_subnet ? 0 : local.enabled_count
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.display_name_prefix}-bastion"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  cidr_block = var.cidr_block

  security_list_ids = oci_core_security_list.bastion.*.id

  dhcp_options_id = var.dhcp_options_id
  dns_label       = "bastion"
}

resource "oci_core_route_table_attachment" "bastion" {
  count          = local.use_existing_subnet ? 0 : local.enabled_count
  subnet_id      = join("", oci_core_subnet.bastion.*.id)
  route_table_id = var.route_table_id
}

data "oci_core_subnet" "bastion" {
  count     = local.use_existing_subnet ? local.enabled_count : 0
  subnet_id = var.existing_subnet_id
}

