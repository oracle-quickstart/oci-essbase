/*
 * Copyright (c) 2019 Oracle and/or its affiliates. All rights reserved.
 */

output "bucket_namespace" {
  value = "${join("", data.oci_objectstorage_namespace.user.*.namespace)}"
}

output "bucket_name" {
  value = "${join("", oci_objectstorage_bucket.data.*.name)}"
}
