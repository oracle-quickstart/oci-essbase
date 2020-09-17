## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  all_cidr = "0.0.0.0/0"
  use_existing_subnet = var.existing_subnet_id != ""
}

resource "oci_core_security_list" "application" {
  count          = local.use_existing_subnet ? 0 : 1
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.display_name_prefix}-application"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  ingress_security_rules {

    protocol  = 6 // tcp
    source    = local.all_cidr
    stateless = false
    description = "Allow inbound traffic to HTTPS"

    tcp_options {
      // These values correspond to the destination port range.
      min = var.instance_listen_port
      max = var.instance_listen_port
    }
  }

  ingress_security_rules {
    // Allow inbound ssh traffic...
    protocol  = 6 // tcp
    source    = local.all_cidr
    stateless = false
    description = "Allow inbound traffic for SSH"

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

resource "oci_core_subnet" "application" {
  count          = local.use_existing_subnet ? 0 : 1
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  display_name   = "${var.display_name_prefix}-application"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  cidr_block = var.cidr_block

  security_list_ids = oci_core_security_list.application.*.id

  dhcp_options_id = var.dhcp_options_id
  dns_label       = "app"

  prohibit_public_ip_on_vnic = var.create_private_subnet
}

resource "oci_core_route_table_attachment" "application" {
  count          = local.use_existing_subnet ? 0 : 1
  subnet_id      = join("", oci_core_subnet.application.*.id)
  route_table_id = var.route_table_id
}

data "oci_core_subnet" "application" {
  count     = local.use_existing_subnet ? 1 : 0
  subnet_id = var.existing_subnet_id
}

