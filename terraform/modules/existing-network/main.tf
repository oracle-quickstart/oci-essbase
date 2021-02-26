## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_core_vcn" "vcn" {
  vcn_id = var.existing_vcn_id
}

data "oci_core_subnet" "application" {
  subnet_id = var.existing_application_subnet_id
}

data "oci_core_subnet" "bastion" {
  count     = var.existing_bastion_subnet_id != "" ? 1 : 0
  subnet_id = var.existing_bastion_subnet_id
}

data "oci_core_subnet" "load-balancer" {
  count     = length(var.existing_load_balancer_subnet_ids)
  subnet_id = var.existing_load_balancer_subnet_ids[count.index]
}

