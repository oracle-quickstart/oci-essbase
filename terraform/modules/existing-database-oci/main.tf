## Copyright (c) 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

data "oci_database_database" "database" {
  database_id = var.database_id
}

locals {

  # Note - for some reason, the terraform provider does not return the pdb_name if the database was created without one specified.
  # Here we will default the value to <dbname>_pdb1 as that is created by default.
  pdb_name = var.pdb_name != "" ? var.pdb_name : data.oci_database_database.database.pdb_name != null ? data.oci_database_database.database.pdb_name : format("%s_pdb1", lower(data.oci_database_database.database.db_name)) 

  pdb_connect_string = length(data.oci_database_database.database.connection_strings) == 0 ? "unknown" : replace(data.oci_database_database.database.connection_strings.0.cdb_ip_default, data.oci_database_database.database.db_unique_name, local.pdb_name)
}

