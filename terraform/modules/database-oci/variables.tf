## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

variable "enabled" {
  type    = bool
  default = true
}

variable "database_id" {
  type    = string
}

variable "pdb_name" {
  type    = string
  default = ""
}


