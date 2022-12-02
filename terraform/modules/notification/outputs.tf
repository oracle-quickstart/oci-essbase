## Copyright (c) 2019-2022, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

output "topic_id" {
  value = join("", data.oci_ons_notification_topic.essbase_topic.*.topic_id)
}

