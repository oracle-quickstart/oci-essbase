## Copyright (c) 2020, 2021, Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  use_existing_topic = var.topic_id != ""
}

data "oci_ons_notification_topic" "essbase_topic" {
  count    = local.use_existing_topic ? 1 : 0
  topic_id = var.topic_id
}

