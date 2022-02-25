## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  // If VCN is /16, each tier will get /20
  all_cidr         = "0.0.0.0/0"

  create_internet_gateway = !var.create_private_application_subnet || (var.create_load_balancer_subnet && !var.create_private_load_balancer_subnet)

  create_nat_gateway = var.create_private_application_subnet
}

#
# Virtual Cloud Network
# 
resource "oci_core_vcn" "vcn" {
  cidr_block     = var.vcn_cidr_block
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-vcn"
  dns_label      = var.dns_label
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

data "oci_core_services" "test_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "service_gateway" {
  compartment_id = var.compartment_id
  display_name   = "service-gateway"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
  vcn_id         = oci_core_vcn.vcn.id

  services {
    service_id = data.oci_core_services.test_services.services[0].id
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  count          = local.create_internet_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "internet-gateway"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_route_table" "internet_route_table" {
  count          = local.create_internet_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "internet-route-table"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  route_rules {
    destination       = local.all_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = join("", oci_core_internet_gateway.internet_gateway.*.id)
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  count          = local.create_nat_gateway ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "nat-gateway"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

