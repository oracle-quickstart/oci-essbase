## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

locals {
  // If VCN is /16, each tier will get /20
  all_cidr = "0.0.0.0/0"
}

#
# Virtual Cloud Network
# 
resource "oci_core_vcn" "vcn" {
  count          = "${var.use_existing_vcn ? 0 : 1}"
  cidr_block     = "${var.vcn_cidr}"
  compartment_id = "${var.compartment_id}"
  display_name   = "${var.display_name_prefix}-vcn"
  dns_label      = "${var.dns_label}"
}

locals {
  vcn_id = "${var.use_existing_vcn ? var.existing_vcn_id : join(",", oci_core_vcn.vcn.*.id)}"
}

data "oci_core_vcn" "vcn" {
  vcn_id = "${local.vcn_id}"
}

data "oci_core_services" "test_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

resource "oci_core_service_gateway" "service_gateway" {
  count          = "${var.use_existing_vcn ? 0 : 1}"
  compartment_id = "${var.compartment_id}"
  display_name   = "${var.display_name_prefix}-service-gateway"
  vcn_id         = "${local.vcn_id}"

  services {
    service_id = "${lookup(data.oci_core_services.test_services.services[0], "id")}"
  }
}

resource "oci_core_internet_gateway" "internet_gateway" {
  count          = "${!var.use_existing_vcn && var.enable_internet_gateway ? 1 : 0}"
  compartment_id = "${var.compartment_id}"
  display_name   = "${var.display_name_prefix}-internet-gateway"
  vcn_id         = "${local.vcn_id}"
}

resource "oci_core_route_table" "igw" {
  count          = "${!var.use_existing_vcn && var.enable_internet_gateway ? 1 : 0}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${local.vcn_id}"
  display_name   = "${var.display_name_prefix}-internet-route-table"

  route_rules {
    destination       = "${local.all_cidr}"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${join("", oci_core_internet_gateway.internet_gateway.*.id)}"
  }
}

resource "oci_core_nat_gateway" "nat_gateway" {
  count          = "${!var.use_existing_vcn && var.enable_nat_gateway ? 1 : 0}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${local.vcn_id}"
  display_name   = "${var.display_name_prefix}-nat-gateway"
}

resource "oci_core_route_table" "nat" {
  count          = "${!var.use_existing_vcn && var.enable_nat_gateway ? 1 : 0}"
  compartment_id = "${var.compartment_id}"
  vcn_id         = "${local.vcn_id}"
  display_name   = "${var.display_name_prefix}-nat-route-table"

  route_rules {
    destination       = "${local.all_cidr}"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = "${join("", oci_core_nat_gateway.nat_gateway.*.id)}"
  }
}
