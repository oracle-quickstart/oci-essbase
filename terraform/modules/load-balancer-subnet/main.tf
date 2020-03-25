## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  all_cidr      = "0.0.0.0/0"
  enabled       = "${var.enabled ? 1 : 0}"
  incoming_port = "${var.enable_https ? 443 : 80}"
}

resource "oci_core_security_list" "load-balancer" {
  count          = "${var.use_existing_subnet ? 0 : local.enabled}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${var.vcn_id}"
  display_name   = "${var.display_name_prefix}-load-balancer"

  ingress_security_rules {
    protocol = "6"
    source   = "${local.all_cidr}"

    tcp_options {
      min = "${local.incoming_port}"
      max = "${local.incoming_port}"
    }
  }

  ingress_security_rules {
    // allow inbound icmp traffic of a specific type
    protocol  = 1
    source    = "${local.all_cidr}"
    stateless = false

    icmp_options {
      "type" = 3
      "code" = 4
    }
  }

  egress_security_rules {
    // Allow all outbound traffic
    destination      = "${local.all_cidr}"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

resource "oci_core_subnet" "load-balancer" {
  count          = "${var.use_existing_subnet ? 0 : local.enabled}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${var.vcn_id}"
  display_name   = "${var.display_name_prefix}-load-balancer"

  cidr_block = "${var.cidr_block}"

  security_list_ids = [
    "${oci_core_security_list.load-balancer.*.id}",
  ]

  dhcp_options_id = "${var.dhcp_options_id}"
  dns_label       = "lb"
}

resource "oci_core_route_table_attachment" "load-balancer" {
  count          = "${var.use_existing_subnet ? 0 : local.enabled}"
  subnet_id      = "${join("", oci_core_subnet.load-balancer.*.id)}"
  route_table_id = "${var.route_table_id}"
}

locals {
  lb_subnet_ids   = "${concat(oci_core_subnet.load-balancer.*.id, var.existing_subnet_ids)}"
  lb_subnet_count = "${!var.use_existing_subnet ? 1 : length(var.existing_subnet_ids)}"
}

data "oci_core_subnet" "load-balancer" {
  count     = "${var.enabled ? local.lb_subnet_count : 0}"
  subnet_id = "${element(concat(local.lb_subnet_ids, list("")), count.index)}"
}
