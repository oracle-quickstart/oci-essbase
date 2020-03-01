## Copyright (c) 2020, Oracle and/or its affiliates.
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

output "bucket_namespace" {
  value = join("", data.oci_objectstorage_namespace.user.*.namespace)
}

output "bucket_name" {
  value = join("", oci_objectstorage_bucket.data.*.name)
}

