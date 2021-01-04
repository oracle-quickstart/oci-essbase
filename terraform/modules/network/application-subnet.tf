## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_security_list" "application" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "application"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  ingress_security_rules {

    protocol    = 6 // tcp
    source      = local.all_cidr
    stateless   = false
    description = "Allow inbound traffic to HTTPS"

    tcp_options {
      // These values correspond to the destination port range.
      min = var.instance_listen_port
      max = var.instance_listen_port
    }
  }

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

resource "oci_core_subnet" "application" {
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "application"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  cidr_block        = var.application_subnet_cidr_block
  security_list_ids = [ oci_core_security_list.application.id ]
  dns_label         = "app"

  prohibit_public_ip_on_vnic = var.create_private_application_subnet
}


resource "oci_core_route_table" "application" {
  count          = var.create_private_application_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "application-route-table"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  route_rules {
    destination       = data.oci_core_services.test_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = join("", oci_core_service_gateway.service_gateway.*.id)
  }

  route_rules {
    destination       = local.all_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = join("", oci_core_nat_gateway.nat_gateway.*.id)
  }
}


resource "oci_core_route_table_attachment" "application" {
  subnet_id      = oci_core_subnet.application.id
  route_table_id = var.create_private_application_subnet ? join("", oci_core_route_table.application.*.id) : join("", oci_core_route_table.internet_route_table.*.id)
}

