## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "oci_core_security_list" "storage" {
  count          = var.create_storage_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "storage"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  ingress_security_rules {
    // Allow inbound traffic for ocfs2
    protocol    = 6 // tcp
    source      = var.storage_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = false
    description = "Allow inbound traffic for ocfs2"

    tcp_options {
      // These values correspond to the destination port range.
      min = 7777
      max = 7777
    }
  }

  ingress_security_rules {
    // Allow inbound traffic for ocfs2
    protocol    = 17 // udp
    source      = var.storage_subnet_cidr_block
    source_type = "CIDR_BLOCK"
    stateless   = true
    description = "Allow inbound traffic for ocfs2"

    udp_options {
      // These values correspond to the destination port range.
      min = 7777
      max = 7777
    }
  }

  egress_security_rules {
    // Allow all outbound traffic for ocfs2
    protocol         = 6 // tcp
    destination      = var.storage_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    stateless        = false
    description      = "Allow outbound traffic for ocfs2"

    tcp_options {
      // These values correspond to the destination port range.
      min = 7777
      max = 7777
    }
  }

  egress_security_rules {
    // Allow all outbound traffic for ocfs2
    protocol         = 17 // udp
    destination      = var.storage_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    stateless        = true
    description      = "Allow outbound traffic for ocfs2"

    udp_options {
      // These values correspond to the destination port range.
      min = 7777
      max = 7777
    }
  }

}

resource "oci_core_subnet" "storage" {
  count          = var.create_storage_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "storage"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags

  cidr_block        = var.storage_subnet_cidr_block
  security_list_ids = concat(oci_core_security_list.storage.*.id)

  dns_label                  = "storage"
  prohibit_public_ip_on_vnic = true
}

