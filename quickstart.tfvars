# Please refer to essbase.auto.tfvars.template for complete variables list and help.
# This is a minimum requirement of variable details for quickstart. Not recommended for production.
# Replace with your values and replace as essbase.auto.tfvars in terraform working directory. 
# Run "terraform plan" to validate and correct errors if any.
# Run "terraform apply" to apply plan and create stack.

essbase_listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaaqyxur5zacfln6epkbm46sdu5whf6zepbm43b63rm44d5hnm2ft5a"
essbase_listing_resource_version = "21.3.0.0.2-2201181909"
essbase_listing_resource_id      = "ocid1.image.oc1..aaaaaaaawwjojlc5vned6bvhwynlrinljdp243lhsfjs6j34nrs2mbmza4qq"

tenancy_ocid 					= ""                                     # REPLACE

user_ocid 						= ""                                     # REPLACE
fingerprint						= ""                                     # REPLACE
private_key_path 				= ""                                     # REPLACE
region 							= "us-ashburn-1"                         # REPLACE
compartment_ocid 				= ""                                     # REPLACE
stack_display_name 				= ""                                     # REPLACE

use_existing_vcn 				= "false"
vcn_cidr 						= "10.0.0.0/16"

create_load_balancer 			= "false"

instance_shape 					= "VM.Standard2.4"
instance_availability_domain 	= "KmGu:US-ASHBURN-AD-1"                 # REPLACE
ssh_authorized_keys 			= ""                                     # REPLACE

essbase_admin_username 			= "admin"
essbase_admin_password_id 		= ""                                     # REPLACE

create_public_essbase_instance  = "true"

identity_provider 				= "embedded"

use_existing_db					= "false"
db_admin_password_id 			= ""                                     # REPLACE
db_license_model 				= "BRING_YOUR_OWN_LICENSE"

