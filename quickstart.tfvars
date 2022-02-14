# Please refer to essbase.auto.tfvars.template for complete variables list and help.
# This is a minimum requirement of variable details for quickstart. Not recommended for production.
# Replace with your values and replace as essbase.auto.tfvars in terraform working directory. 
# Run "terraform plan" to validate and correct errors if any.
# Run "terraform apply" to apply plan and create stack.

essbase_listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaaqyxur5zacfln6epkbm46sdu5whf6zepbm43b63rm44d5hnm2ft5a"
essbase_listing_resource_version = "21.3.0.0.2-2201181909"
essbase_listing_resource_id      = "ocid1.image.oc1..aaaaaaaawwjojlc5vned6bvhwynlrinljdp243lhsfjs6j34nrs2mbmza4qq"

tenancy_ocid 					= "ocid1.tenancy.oc1..aaaaaaaaqfirhnfnpcttjlr4fgedsket5y2miv3zywjidvaxhnlyujhjn6mq" 		# REPLACE

user_ocid 						= "ocid1.user.oc1..aaaaaaaa3dz4v6fyym3gyv4e4m3sakkzkuqgglawhcnwhkculbys4ldgthuq" 			# REPLACE
fingerprint						= "72:6e:91:a9:fc:5a:34:8c:f7:09:f6:50:9c:83:33:2d" 										# REPLACE
private_key_path 				= "./oci_api_key.pem" 																		# REPLACE
region 							= "us-ashburn-1" 																			# REPLACE
compartment_ocid 				= "ocid1.compartment.oc1..aaaaaaaav5qjcphte2sos4uaxa7ra5ylun32pta3o2j7sxyybdf27uroff6a" 	# REPLACE
stack_display_name 				= "Test_github" 																			# REPLACE

use_existing_vcn 				= "false"
vcn_cidr 						= "10.0.0.0/16"

create_load_balancer 			= "false"

instance_shape 					= "VM.Standard2.4"
instance_availability_domain 	= "KmGu:US-ASHBURN-AD-1" 																	# REPLACE
ssh_authorized_keys 			= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDRcAsr+J4QPDiP04oHSGRQlHyMWKlr5NvB2vMcIq+UMEQaEV3iY+Lwff60MgOO/LdGwGzrD2FWkVokS/faLtfUCimzA3UoWp8ijj4l/xEg/czoocJ4PDAWrBZIPOhjwfZ2h50tDtFhUFZPOVq0gk/oNwbArcQy6KhXcdPUD77InIwb2B0V2WevFHuVcGU9FYxkOGlMyhXRaoTEjhFEOqmpOJIaBZbSJlzz4vx+QswPTkwHpIOu/PTQTEXaMYecbcZ0k2PdZZVRUsn72DsPysEJVHYClCbPNnLR+GtHIUu4uLal33V8roxyYRLP8DRHnh6oNMSxrN4oZ/HyqNw2+tdh ssh-key-2020-10-19" 
																															# REPLACE

essbase_admin_username 			= "admin"
essbase_admin_password_id 		= "ocid1.vaultsecret.oc1.iad.amaaaaaa63ksotiaidys4xt5kgtnhrpoldpuj5lsvr2swqw2deoubuuhj3da"  # REPLACE

create_public_essbase_instance  = "true"

identity_provider 				= "embedded"

use_existing_db					= "false"
db_admin_password_id 			= "ocid1.vaultsecret.oc1.iad.amaaaaaa63ksotiaoddlvvslp7oozj3ppsjr4hzroe5dinvjtuu4u6doje4a"  # REPLACE
db_license_model 				= "BRING_YOUR_OWN_LICENSE"

