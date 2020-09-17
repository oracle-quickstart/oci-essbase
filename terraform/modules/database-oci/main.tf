## Copyright (c) 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_database_database" "database" {
  count       = var.enabled ? 1 : 0
  database_id = var.database_id
}

locals {

  # Note - for some reason, the terraform provider does not return the pdb_name if the database was created without one specified.
  # Here we will default the value to <dbname>_pdb1 as that is created by default.
  pdb_name_list = [
    for i in data.oci_database_database.database:
       (i.pdb_name != null ? i.pdb_name : format("%s_pdb1", lower(i.db_name)))
  ]
  pdb_name = var.pdb_name != "" ? var.pdb_name : join("", local.pdb_name_list)

  pdb_connect_string_list = [
    for i in data.oci_database_database.database:
       length(i.connection_strings) == 0 ? "unknown" : replace(i.connection_strings.0.cdb_ip_default, i.db_unique_name, var.pdb_name != "" ? var.pdb_name : (i.pdb_name != null ? i.pdb_name : format("%s_pdb1", lower(i.db_name))))
  ]
  pdb_connect_string = join("", local.pdb_connect_string_list)

}

