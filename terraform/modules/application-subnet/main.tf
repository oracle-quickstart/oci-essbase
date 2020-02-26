## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  all_cidr = "0.0.0.0/0"
}

resource "oci_core_security_list" "application" {
  count          = "${var.use_existing_subnet ? 0 : 1}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${var.vcn_id}"
  display_name   = "${var.display_name_prefix}-application"

  ingress_security_rules {
    // Allow inbound traffic to WLS ports
    protocol  = "6"                 // tcp
    source    = "${local.all_cidr}"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = "80"
      max = "80"
    }
  }

  ingress_security_rules {
    // Allow inbound traffic to WLS ports
    protocol  = "6"                 // tcp
    source    = "${local.all_cidr}"
    stateless = false

    tcp_options {
      // These values correspond to the destination port range.
      min = "443"
      max = "443"
    }
  }

  ingress_security_rules {
    // Allow inbound ssh traffic for now...
    protocol  = "6"                 // tcp
    source    = "${local.all_cidr}"
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
    source    = "${local.all_cidr}"
    stateless = false

    icmp_options {
      type = 3
      code = 4
    }
  }

  egress_security_rules {
    // Allow all outbound traffic
    destination      = "${local.all_cidr}"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

resource "oci_core_subnet" "application" {
  count          = "${var.use_existing_subnet ? 0 : 1}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${var.vcn_id}"
  display_name   = "${var.display_name_prefix}-application"

  cidr_block = "${var.cidr_block}"

  security_list_ids = [
    "${oci_core_security_list.application.*.id}",
  ]

  dhcp_options_id = "${var.dhcp_options_id}"
  dns_label       = "app"

  prohibit_public_ip_on_vnic = "${var.create_private_subnet ? 1 : 0}"
}

resource "oci_core_route_table_attachment" "application" {
  count          = "${var.use_existing_subnet ? 0 : 1}"
  subnet_id      = "${join("", oci_core_subnet.application.*.id)}"
  route_table_id = "${var.route_table_id}"
}

locals {
  application_subnet_id = "${var.use_existing_subnet ? var.existing_subnet_id : join(",", oci_core_subnet.application.*.id)}"
}

data "oci_core_subnet" "application" {
  subnet_id = "${local.application_subnet_id}"
}
