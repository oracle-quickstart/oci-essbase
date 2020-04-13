## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

locals {
  // If VCN is /16, each tier will get /20
  all_cidr = "0.0.0.0/0"
  use_existing_vcn = var.existing_vcn_id != ""
}

#
# Virtual Cloud Network
# 
resource "oci_core_vcn" "vcn" {
  count          = local.use_existing_vcn ? 0 : 1
  cidr_block     = var.vcn_cidr
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-vcn"
  dns_label      = var.dns_label
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

data "oci_core_vcn" "vcn" {
  count          = local.use_existing_vcn ? 1 : 0
  vcn_id         = var.existing_vcn_id
}

locals {
  vcn_id         = local.use_existing_vcn ? join("", data.oci_core_vcn.vcn.*.id) : join("", oci_core_vcn.vcn.*.id)
  compartment_id = local.use_existing_vcn ? join("", data.oci_core_vcn.vcn.*.compartment_id) : join("", oci_core_vcn.vcn.*.compartment_id)
}

data "oci_core_services" "test_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "service_gateway" {
  count          = local.use_existing_vcn ? 0 : 1
  compartment_id = local.compartment_id
  display_name   = "${var.display_name_prefix}-service-gateway"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
  vcn_id         = local.vcn_id

  services {
    service_id = data.oci_core_services.test_services.services[0].id
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  count          = !local.use_existing_vcn && var.enable_internet_gateway ? 1 : 0
  compartment_id = local.compartment_id
  display_name   = "${var.display_name_prefix}-internet-gateway"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
  vcn_id         = local.vcn_id
}

resource "oci_core_route_table" "igw" {
  count          = !local.use_existing_vcn && var.enable_internet_gateway ? 1 : 0
  compartment_id = local.compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.display_name_prefix}-internet-route-table"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  route_rules {
    destination       = local.all_cidr
    destination_type  = "CIDR_BLOCK"
    network_entity_id = join("", oci_core_internet_gateway.internet_gateway.*.id)
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  count          = !local.use_existing_vcn && var.enable_nat_gateway ? 1 : 0
  compartment_id = local.compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.display_name_prefix}-nat-gateway"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

resource "oci_core_route_table" "nat" {
  count          = !local.use_existing_vcn && var.enable_nat_gateway ? 1 : 0
  compartment_id = local.compartment_id
  vcn_id         = local.vcn_id
  display_name   = "${var.display_name_prefix}-nat-route-table"
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

