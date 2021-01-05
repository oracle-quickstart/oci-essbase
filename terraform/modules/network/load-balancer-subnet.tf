## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  incoming_port       = 443
}

resource "oci_core_security_list" "load-balancer" {
  count          = var.create_load_balancer_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "load-balancer"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  ingress_security_rules {
    protocol    = 6
    source      = local.all_cidr
    description = "Allow inbound traffic for HTTPS"

    tcp_options {
      min = local.incoming_port
      max = local.incoming_port
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
    destination      = var.application_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
  }
}

resource "oci_core_subnet" "load-balancer" {
  count          = var.create_load_balancer_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "load-balancer"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  cidr_block                 = var.load_balancer_subnet_cidr_block
  prohibit_public_ip_on_vnic = var.create_private_load_balancer_subnet
  security_list_ids          = oci_core_security_list.load-balancer.*.id

  dns_label       = "lb"
}

resource "oci_core_route_table_attachment" "load-balancer" {
  count          = var.create_load_balancer_subnet && ! var.create_private_load_balancer_subnet ? 1 : 0
  subnet_id      = join("", oci_core_subnet.load-balancer.*.id)
  route_table_id = join("", oci_core_route_table.internet_route_table.*.id)
}

