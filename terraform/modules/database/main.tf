## Copyright (c) 2019 - 2022, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

resource "random_password" "bootstrap_password_1" {
  length  = 1
  upper   = true
  lower   = true
  number  = false
  special = false
}

resource "random_password" "bootstrap_password_2" {
  length           = 24
  upper            = true
  min_upper        = 2
  lower            = true
  min_lower        = 2
  number           = true
  min_numeric      = 2
  special          = true
  override_special = "#_$"
  min_special      = 2
}

locals {
  bootstrap_password = "${random_password.bootstrap_password_1.result}${random_password.bootstrap_password_2.result}"
}

resource "oci_core_network_security_group" "vcn_nsg" {
  
  count          = local.secure_count == 1 ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = var.vcn_id
  
}

resource "oci_core_network_security_group_security_rule" "vcn_nsg_rule" {
  
  count          = local.secure_count == 1 ? 1 : 0
  # oci_core_network_security_group.vcn_nsg[count.index]

  network_security_group_id = oci_core_network_security_group.vcn_nsg[count.index].id
  description = "HTTPS"
  direction   = "INGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = local.all_cidr
  tcp_options {
    destination_port_range {
      min = 443
      max = 443
    }
  }
}

resource "oci_core_network_security_group_security_rule" "vcn_nsg_rule1" {
  
  count          = local.secure_count == 1 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.vcn_nsg[count.index].id
  description = "HTTPS"
  direction   = "INGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = local.all_cidr
  tcp_options {
    destination_port_range {
      min = 1522
      max = 1522
    }
  }
}

resource "oci_core_network_security_group_security_rule" "vcn_nsg_rule2" {
  
  count          = local.secure_count == 1 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.vcn_nsg[count.index].id
  description = "HTTPS"
  direction   = "INGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = local.all_cidr
  tcp_options {
    destination_port_range {
      min = 3389
      max = 3389
    }
  }
}

resource "oci_core_network_security_group_security_rule" "vcn_nsg_rule3" {
  
  count          = local.secure_count == 1 ? 1 : 0
  network_security_group_id = oci_core_network_security_group.vcn_nsg[count.index].id
  description = "HTTPS"
  direction   = "EGRESS"
  protocol    = 6
  source_type = "CIDR_BLOCK"
  source      = local.all_cidr
  destination = local.all_cidr
}


resource "oci_database_autonomous_database" "autonomous_database" {
  admin_password           = local.bootstrap_password
  compartment_id           = var.compartment_id
  cpu_core_count           = "1"
  data_storage_size_in_tbs = "1"
  db_name                  = var.db_name
  db_workload              = var.db_workload == "Autonomous Transaction Processing" ? "OLTP" : "DW"
  is_auto_scaling_enabled  = true
  subnet_id = local.secure_count == 1 ? var.subnet_id : null
  nsg_ids = local.secure_count == 1 ? [oci_core_network_security_group.vcn_nsg[0].id] : null
  
  display_name  = "${var.display_name_prefix}-database"
  freeform_tags = var.freeform_tags
  defined_tags  = var.defined_tags
  license_model = var.license_model
  
  depends_on = [
    oci_core_network_security_group.vcn_nsg
  ]

  timeouts {
    create = "30m"
  }
}

locals {
  
  all_cidr     = "0.0.0.0/0"
  secure_count = var.create_secure_db ? 1 : 0
  db_name      = oci_database_autonomous_database.autonomous_database.db_name
  is_dedicated = oci_database_autonomous_database.autonomous_database.is_dedicated

  private_endpoint    = oci_database_autonomous_database.autonomous_database.private_endpoint
  private_endpoint_ip = oci_database_autonomous_database.autonomous_database.private_endpoint_ip
}
