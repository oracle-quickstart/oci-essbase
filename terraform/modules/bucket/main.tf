## Copyright (c) 2019, 2020, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at http://oss.oracle.com/licenses/upl.

data "oci_objectstorage_namespace" "user" {
  count = var.enabled ? 1 : 0
  # TODO Enable  # compartment_id = "${var.compartment_id}"
}

resource "oci_objectstorage_bucket" "data" {
  count          = var.enabled ? 1 : 0
  compartment_id = var.compartment_id
  namespace      = join("", data.oci_objectstorage_namespace.user.*.namespace)
  name           = var.bucket_name
  access_type    = "NoPublicAccess"
  freeform_tags  = var.freeform_tags
  defined_tags   = var.defined_tags
}

