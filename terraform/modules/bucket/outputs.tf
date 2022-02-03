## Copyright (c) 2019, 2021, 2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "id" {
  value = oci_objectstorage_bucket.data.id
}

output "namespace" {
  value = data.oci_objectstorage_namespace.user.namespace
}

output "name" {
  value = oci_objectstorage_bucket.data.name
}

