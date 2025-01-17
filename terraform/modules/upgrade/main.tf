## Copyright (c) 2019 - 2023 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

locals {
  enable_subscription = var.listing_id != ""
}

# Get Image Agreement
resource "oci_core_app_catalog_listing_resource_version_agreement" "essbase_image_agreement" {
  count = local.enable_subscription ? 1 : 0

  listing_id               = var.listing_id
  listing_resource_version = var.listing_resource_version
}

# Accept Terms and Subscribe to the image, placing the image in a particular compartment
resource "oci_core_app_catalog_subscription" "essbase_image_subscription" {
  count                    = local.enable_subscription ? 1 : 0
  compartment_id           = var.compartment_ocid
  eula_link                = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].eula_link
  listing_id               = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].listing_id
  listing_resource_version = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].listing_resource_version
  oracle_terms_of_use_link = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].oracle_terms_of_use_link
  signature                = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].signature
  time_retrieved           = oci_core_app_catalog_listing_resource_version_agreement.essbase_image_agreement[0].time_retrieved

  timeouts {
    create = "20m"
  }
}

locals {
  image_id = local.enable_subscription ? join("", oci_core_app_catalog_subscription.essbase_image_subscription.*.listing_resource_id) : var.listing_resource_id
  stack_resource_id = data.oci_core_instance.source_instance.metadata.stack_display_name
  stack_resource_id_escaped = replace(local.stack_resource_id, "-", "_")
  stack_id = data.oci_core_instance.source_instance.metadata.stack_id
  source_instance_ocpus = join("", data.oci_core_instance.source_instance.shape_config[*].ocpus)
  upgrade_instance_shape = (var.instanceUpgradeShape == "Upgrade to recommended Flex Shape") ? "VM.Standard.E5.Flex" : data.oci_core_instance.source_instance.shape
  #upgrade_instance_ocpus = (var.instanceUpgradeShape == "Upgrade to recommended Flex Shape") ? 4 : local.source_instance_ocpus
  upgrade_instance_ocpus = local.source_instance_ocpus
}

data "oci_core_instance" "source_instance" {
    #Required
    instance_id = var.sourceInstance_ocid
}

data "oci_core_volume_attachments" "test_volume_attachments" {
    #Required
    compartment_id = var.compartment_ocid
    instance_id = var.sourceInstance_ocid

    filter {
      name   = "state"
      values = ["ATTACHED"]
    }
    
    filter {
      name   = "display_name"
      values = ["\\w*config-volume\\w*","\\w*data-volume\\w*","\\w*temp-volume\\w*"]
      regex = true
    }
}

data "oci_objectstorage_bucket" "source_bucket" {
	#Required
  name = var.instanceUpgrade19c02 ? oci_objectstorage_bucket.metadata_bucket19c02[0].name :local.target_extendedMetadata.metadata_bucket.name
	namespace = var.instanceUpgrade19c02 ? oci_objectstorage_bucket.metadata_bucket19c02[0].namespace :local.target_extendedMetadata.metadata_bucket.namespace
}

resource "oci_objectstorage_object" "target_volumeMetadata" {
  count=length(local.source_volumeAttachments)

  bucket       = data.oci_objectstorage_bucket.source_bucket.name
  namespace    = data.oci_objectstorage_bucket.source_bucket.namespace
  object       = format("%s/%s.dat", 
                  oci_core_instance.target_instance.id, 
                  oci_core_volume_attachment.targetVolumeAttachment[count.index].volume_id
                  )
  storage_tier = "InfrequentAccess"
  content = jsonencode({
     "iqn"  = oci_core_volume_attachment.targetVolumeAttachment[count.index].iqn,
     "ipv4" = oci_core_volume_attachment.targetVolumeAttachment[count.index].ipv4,
     "port" = oci_core_volume_attachment.targetVolumeAttachment[count.index].port,
     "type" = format("%s", 
                      split("-", oci_core_volume.targetVolume[count.index].display_name)[1]
                    )
  
     "volumeid" = oci_core_volume_attachment.targetVolumeAttachment[count.index].volume_id
   })
}

resource "oci_objectstorage_object" "target_volumeUpgrade" {
  count=length(local.source_volumeAttachments)

  bucket       = data.oci_objectstorage_bucket.source_bucket.name
  namespace    = data.oci_objectstorage_bucket.source_bucket.namespace
  object       = format("%s/%s.dat", 
                  oci_core_instance.target_instance.id, 
                  split("-", oci_core_volume.targetVolume[count.index].display_name)[1]
                  )
  storage_tier = "InfrequentAccess"
  content = jsonencode({
     "volumeid" = oci_core_volume_attachment.targetVolumeAttachment[count.index].volume_id
     "mountpoint" = format("/u01/%s", 
                      split("-", oci_core_volume.targetVolume[count.index].display_name)[1]
                    )
   })
}

data "oci_core_vnic_attachments" "source_vnic_attachments" {
    #Required
    compartment_id = var.compartment_ocid

    #Optional
    instance_id = data.oci_core_instance.source_instance.id
}

data "oci_core_vnic" "source_vnic" {
     #Required
    vnic_id = data.oci_core_vnic_attachments.source_vnic_attachments.vnic_attachments[0].vnic_id
}

locals {
  target_testIP           = data.oci_core_instance.source_instance.private_ip
  target_privateIP        = var.instanceSpecifyPrivateIP ? var.instancePrivateIP :  null
  target_metadata         = ( var.instanceUpgrade19c23 || var.instanceUpgrade19c02 ) ? local.target_metadata19c23: data.oci_core_instance.source_instance.metadata

  string_target_extendedMetadata = var.instanceUpgrade19c02 ? jsonencode(local.target_extendedMetadata19c02): jsonencode(local.build_extmetadata)
  target_extendedMetadata = jsondecode(local.string_target_extendedMetadata)

  source_volumeAttachments = data.oci_core_volume_attachments.test_volume_attachments.volume_attachments
  source_VNIChostname      = tostring(data.oci_core_vnic.source_vnic.hostname_label)
  source_displayname       = tostring(data.oci_core_instance.source_instance.display_name)

  target_displayname = format("%s_1", local.stack_resource_id)
  target_hostname    = format("%s_1", local.source_VNIChostname)

#Create user_data including cloud-init for 19c23 Upgrade Instance
    cloud_init19c23 = <<TMPL
Content-Type: multipart/mixed; boundary="boundary-0123456789"
MIME-Version: 1.0

--boundary-0123456789
MIME-Version: 1.0
Content-Type: text/cloud-config; charset="us-ascii"

#cloud-config
# vim: syntax=yaml
runcmd:
- /u01/vmtools/init/essbase-init.sh
--boundary-0123456789--
TMPL

  cloud_init19c23_encoded= ( var.instanceUpgrade19c23 || var.instanceUpgrade19c02 ) ? base64gzip(local.cloud_init19c23): null

  # Adding the user_data field into existing metadata from source instance
  # Steps: filter out old user_data, insert created user_data 
  filtered_metadata = ( var.instanceUpgrade19c23 || var.instanceUpgrade19c02 ) ? { for k, v in data.oci_core_instance.source_instance.metadata: k => v if ! (k== "user_data") }: null
  new_user_data = ( var.instanceUpgrade19c23 || var.instanceUpgrade19c02 ) ? tomap({user_data = local.cloud_init19c23_encoded}): null
  target_metadata19c23 = ( var.instanceUpgrade19c23 || var.instanceUpgrade19c02 ) ? merge(local.filtered_metadata, local.new_user_data) : null
  
  #19c02

  build_extmetadata = jsondecode(var.sourceInstance_extendedMetadata)
  bucket_info_19c02 = var.instanceUpgrade19c02 ? {
    id="null"
    name=oci_objectstorage_bucket.metadata_bucket19c02[0].name
    namespace=data.oci_objectstorage_namespace.objectstorage_ns.namespace
  }: null
  new_metadata_bucket = var.instanceUpgrade19c02 ? tomap({metadata_bucket = local.bucket_info_19c02}): null
  target_extendedMetadata19c02 = var.instanceUpgrade19c02 ? merge(local.build_extmetadata, local.new_metadata_bucket) : null
}

resource "oci_core_volume" "targetVolume" {
  count=length(local.source_volumeAttachments) 
  
  compartment_id = var.compartment_ocid

  display_name = (var.instanceUpgrade19c34 || var.instanceUpgrade19c23 || var.instanceUpgrade19c02 || var.instanceUpgrade21c01) ? format(
    "%s_1-%s-volume", local.stack_resource_id_escaped, 
    strrev(split("-",strrev(tostring(local.source_volumeAttachments[count.index].display_name)))[(var.instanceUpgrade19c23 || var.instanceUpgrade19c02)?3:2])
  ):format(
    "%s_1-%s", local.stack_resource_id_escaped, tostring(local.source_volumeAttachments[count.index].display_name)) 
 
  # Since extended metadata is not currently available from Terraform (bug)
  # Volume type & ID is determined from source volume attachment 

  availability_domain = local.source_volumeAttachments[count.index].availability_domain
  source_details{
    id = local.source_volumeAttachments[count.index].volume_id
    type = "volume"
  }
}

resource "oci_core_volume_attachment" "targetVolumeAttachment" {
    count = length(local.source_volumeAttachments)

    attachment_type = "iscsi"
    instance_id = oci_core_instance.target_instance.id
    volume_id = oci_core_volume.targetVolume[count.index].id
    display_name = format( "%s-volume", strrev(split("-", strrev(tostring(oci_core_volume.targetVolume[count.index].display_name)))[1]))
}

resource "oci_core_instance" "target_instance" {

  availability_domain = data.oci_core_instance.source_instance.availability_domain
  compartment_id = "${var.compartment_ocid}"
  display_name = local.target_displayname
  #shape = data.oci_core_instance.source_instance.shape
  shape = local.upgrade_instance_shape
  #dynamic "shape_config" {
    #for_each = data.oci_core_instance.source_instance.shape_config
    #for_each = data.oci_core_instance.target_instance.shape_config
    #content {
     # ocpus = shape_config.value.ocpus
    #}
    shape_config {
      ocpus = local.upgrade_instance_ocpus
    }
  

  create_vnic_details {
      subnet_id = data.oci_core_vnic.source_vnic.subnet_id
      display_name = local.target_hostname
      assign_public_ip = data.oci_core_instance.source_instance.public_ip != ""
      private_ip = local.target_privateIP
  }

  agent_config {
    #Optional
    are_all_plugins_disabled = false
    is_management_disabled = false
    is_monitoring_disabled = false
 }
	
  source_details {
    source_type = "image"
    source_id = "${var.instanceImage_ocid}"
  }
 
  metadata = local.target_metadata

  extended_metadata = {
    source_extended = jsonencode(local.target_extendedMetadata)
    source_instance_ocid = var.sourceInstance_ocid
    source_hostname = local.source_VNIChostname
    source_version = var.sourceInstance_version
    
    source_backup_restore = var.instanceBackupRestore
    target_schema_prefix = var.instanceBackupRestore? var.instanceSchemaPrefix: null
    
    backup_IDCS_secret = var.instanceIDCSPassword!="" ? var.instanceIDCSPassword: null
    backup_db_password = var.instanceDBPassword!="" ? var.instanceDBPassword: null
    backup_essbase_password = var.instanceEssbasePassword!="" ? var.instanceEssbasePassword: null
  }

  timeouts {
    create = "60m"
  }
}

resource "oci_objectstorage_object" "essbase_cluster_metadata" {
  bucket       = var.instanceUpgrade19c02 ?  oci_objectstorage_bucket.metadata_bucket19c02[0].name: data.oci_objectstorage_bucket.source_bucket.name
  namespace    = var.instanceUpgrade19c02 ?  oci_objectstorage_bucket.metadata_bucket19c02[0].namespace: data.oci_objectstorage_bucket.source_bucket.namespace 
  count        = (var.instanceUpgrade19c34 || var.instanceUpgrade19c23 || var.instanceUpgrade19c02)? 1:0

  object       = "cluster-info.dat"
  storage_tier = "InfrequentAccess"
  content      = "{}"
}

#Create for 19c23 upgrade as 19c23 had only config and data volumes
resource "oci_core_volume" "tempVolume19c23" {
  count=(var.instanceUpgrade19c23 || var.instanceUpgrade19c02)?1:0 
  
  compartment_id = var.compartment_ocid

  display_name = format(
    "%s_1-%s-volume", local.stack_resource_id_escaped, "temp"
  )
  
  availability_domain = local.source_volumeAttachments[0].availability_domain
  size_in_gbs  = 64
}

#Create for 19c23 upgrade as 19c23 had only config and data volumes
resource "oci_core_volume_attachment" "tempVolumeAttachment19c23" {
  count=(var.instanceUpgrade19c23 || var.instanceUpgrade19c02)?1:0 

    attachment_type = "iscsi"
    instance_id = oci_core_instance.target_instance.id
    volume_id = oci_core_volume.tempVolume19c23[count.index].id
    display_name = format( "%s-volume", "temp")
}

#Create for 19c23 upgrade as 19c23 had only config and data volumes
resource "oci_objectstorage_object" "target_tempVolume19c23Upgrade" {
  count=(var.instanceUpgrade19c23 || var.instanceUpgrade19c02)?1:0 

  bucket       = data.oci_objectstorage_bucket.source_bucket.name
  namespace    = data.oci_objectstorage_bucket.source_bucket.namespace
  object       = format("%s/%s.dat", 
                  oci_core_instance.target_instance.id, 
                  split("-", oci_core_volume.tempVolume19c23[count.index].display_name)[1]
                  )

  storage_tier = "InfrequentAccess"
  content = jsonencode({
     "volumeid" = oci_core_volume_attachment.tempVolumeAttachment19c23[count.index].volume_id
     "mountpoint" = format("/u01/%s", 
                      split("-", oci_core_volume.tempVolume19c23[count.index].display_name)[1]
                    )
   })
}

resource "oci_objectstorage_object" "target_tempVolume19c23Metadata" {
  count=(var.instanceUpgrade19c23 || var.instanceUpgrade19c02)?1:0

  bucket       = data.oci_objectstorage_bucket.source_bucket.name
  namespace    = data.oci_objectstorage_bucket.source_bucket.namespace
  object       = format("%s/%s.dat", 
                  oci_core_instance.target_instance.id, 
                  oci_core_volume_attachment.tempVolumeAttachment19c23[count.index].volume_id
                  )
  storage_tier = "InfrequentAccess"
  content = jsonencode({
     "iqn"  = oci_core_volume_attachment.tempVolumeAttachment19c23[count.index].iqn,
     "ipv4" = oci_core_volume_attachment.tempVolumeAttachment19c23[count.index].ipv4,
     "port" = oci_core_volume_attachment.tempVolumeAttachment19c23[count.index].port,
     "type" = format("%s", 
                      split("-", oci_core_volume.tempVolume19c23[count.index].display_name)[1]
                    )
  
     "volumeid" = oci_core_volume_attachment.tempVolumeAttachment19c23[count.index].volume_id
   })
}

data "oci_objectstorage_namespace" "objectstorage_ns" {

}

resource "oci_objectstorage_bucket" "metadata_bucket19c02" {
  count = var.instanceUpgrade19c02?1:0
  compartment_id = var.compartment_ocid
  namespace      = data.oci_objectstorage_namespace.objectstorage_ns.namespace
  name           = var.bucket_name
  access_type    = "NoPublicAccess"
}
