## Copyright (c) 2019, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "bucket_namespace" {
  value = join("", data.oci_objectstorage_namespace.user.*.namespace)
}

output "bucket_name" {
  value = join("", oci_objectstorage_bucket.data.*.name)
}

