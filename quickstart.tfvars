# Please refer to essbase.auto.tfvars.template for complete variables list and help.
# This is a minimum requirement of variable details for quickstart. Not recommended for production.
# Replace with your values and replace as essbase.auto.tfvars in terraform working directory. 
# Run "terraform plan" to validate and correct errors if any.
# Run "terraform apply" to apply plan and create stack.

essbase_listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaaqyxur5zacfln6epkbm46sdu5whf6zepbm43b63rm44d5hnm2ft5a"
essbase_listing_resource_version = "21.4.0.0.1_2209301529"
essbase_listing_resource_id      = "ocid1.image.oc1..aaaaaaaayqzkbfw6byytpgmmp5s2kv64ipqa5gkxyhc23tuqptalqipsjkpq"

tenancy_ocid 					= "" 		                # REPLACE

user_ocid 						= "" 			            # REPLACE
fingerprint						= "" 						# REPLACE
private_key_path 				= "" 						# REPLACE
region 							= "us-ashburn-1" 			# REPLACE
compartment_ocid 				= "" 	                    # REPLACE
stack_display_name 				= "" 						# REPLACE

use_existing_vcn 				= "false"
vcn_cidr 						= "10.0.0.0/16"

create_load_balancer 			= "false"

instance_shape 					= "VM.Standard2.4"
instance_availability_domain 	= "KmGu:US-ASHBURN-AD-1" 	# REPLACE
ssh_authorized_keys 			= ""
																														

essbase_admin_username 			= "admin"
essbase_admin_password_id 		= ""                        # REPLACE

create_public_essbase_instance  = "true"

identity_provider 				= "embedded"

use_existing_db					= "false"
db_admin_password_id 			= ""                        # REPLACE
db_license_model 				= "BRING_YOUR_OWN_LICENSE"


# IN CASE OF UPGRADE PROVIDE BELOW DETAILS

is_upgrade                      = "false"                        # REPLACE WITH TRUE IF UPGRADE CASE ELSE FALSE
upgrade_backup_restore          = "Essbase 21c - 21.3 or above"                        # REPLACE WITH "Essbase 21c - 21.3 or above" OR "Essbase 19c - 19.3.0.5.6 or above" OR "Essbase 19c - 19.3.0.3.4, 19.3.0.4.5" ACCORDINGLY
sourceInstance_ocid             = ""
sourceInstance_extendedMetadata = <<-EOF

EOF
# Check documentation if you need to run upgrade-metadata-19c.sh script to prepare the source instance for upgrade.                                                    
# REPLACE LINE 48 WITH EXTENDED METADATA WITH COMMAND OUTPUT FROM SOURCE INSTANCE:
# oci compute instance get --instance-id $(oci-metadata -j | jq -r '.instance.id') --auth instance_principal | jq '.data."extended-metadata"'
