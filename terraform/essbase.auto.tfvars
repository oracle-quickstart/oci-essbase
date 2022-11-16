## Copyright (c) 2019-2022 Oracle and/or its affiliates.
## Licensed under the Universal Permissive License v1.0 as shown at https://oss.oracle.com/licenses/upl.

# Listing details for the Essbase custom image for Bring Your Own License.
essbase_listing_id               = "ocid1.appcataloglisting.oc1..aaaaaaaaqyxur5zacfln6epkbm46sdu5whf6zepbm43b63rm44d5hnm2ft5a"
essbase_listing_resource_version = "19.3.0.6.0_2211031515"
essbase_listing_resource_id      = "ocid1.image.oc1..aaaaaaaa7qcveql4v2fkdhcooxrx4zel2qkjmsjhgl5abgt445kdcfrngfxq"


###



tenancy_ocid 					= "ocid1.tenancy.oc1..aaaaaaaaqfirhnfnpcttjlr4fgedsket5y2miv3zywjidvaxhnlyujhjn6mq" 		# REPLACE

user_ocid 						= "ocid1.user.oc1..aaaaaaaa3dz4v6fyym3gyv4e4m3sakkzkuqgglawhcnwhkculbys4ldgthuq" 			# REPLACE
fingerprint						= "72:6e:91:a9:fc:5a:34:8c:f7:09:f6:50:9c:83:33:2d" 										# REPLACE
private_key_path 				= "./oci_api_key.pem" 																		# REPLACE
region 							= "us-ashburn-1" 																			# REPLACE
compartment_ocid 				= "ocid1.compartment.oc1..aaaaaaaav5qjcphte2sos4uaxa7ra5ylun32pta3o2j7sxyybdf27uroff6a" 	# REPLACE
stack_display_name 				= "github_193060" 																			# REPLACE

use_existing_vcn 				= "false"
vcn_cidr 						= "10.0.0.0/16"

create_load_balancer 			= "false"

instance_shape 					= "VM.Standard2.4"
instance_availability_domain 	= "KmGu:US-ASHBURN-AD-1" 																	# REPLACE
ssh_authorized_keys 			= "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCh8oYETXdCLGV482kDbWOBMnqx0S3eZj55w2UJREVPrYM3RNraa37FYF+bXgGTHSYBPc0La9YL+VLYFe6tR/tJIcMFGxQH2PWZH+sKBR2alhamI8VPl4J+nwppL7LJ+TviArv0/VEmtOzclirRgPnuRJy4oDUkLRMdW6QBdYZEZk+zZANoKqF0dXxETt4RZa9yu/JOtge/9hOBLD9jK0MIFXCEA5lV6gGOtOF1ahOqFDD64X94Xs5pSOUczAcgqdQDDRztia7kuSQP195GxIkAt1NtCmG8zQanSzVlJ/oAQTTaGr9WELFlOxK2AJkvJmTYaV6HGrtV/XuGCVRLVlzyrE4wMJfFPD8Vvrsng+5NXFbMoNVzQlbILK3JsnJVWO949w0ZieGL9py5A1VL0+/MyC6X7atSQ1czQurNDrEgFIeK0fxN3SvrGSFYBbX8+/krsHYFEbqnLaDoroVvONOiEM4VUe8be63qPtAYCq5LD2YrJtICZdYZUiC+2hP79A7f6FRP63ukLenyVcXhUvPNlhL1LQsaJ6of4MQYHL7QABrL0GhzLqIUVabA79vJWDP4C6AiKyUJd3A33G5tw5FXq1tpNYwHoo90ewbbDSa6bpTeft2aETIzU7tnCRW9GBFacRMGjapKKihP5OcINGNHMsh72s7fDKhmGaQc39OxPw== MPcommonkey" 
																															# REPLACE

essbase_admin_username 			= "admin"
essbase_admin_password_id 		= "ocid1.vaultsecret.oc1.iad.amaaaaaa63ksotiaoddlvvslp7oozj3ppsjr4hzroe5dinvjtuu4u6doje4a"  # REPLACE

create_public_essbase_instance  = "true"

identity_provider 				= "embedded"

use_existing_db					= "false"
db_admin_password_id 			= "ocid1.vaultsecret.oc1.iad.amaaaaaa63ksotiaoddlvvslp7oozj3ppsjr4hzroe5dinvjtuu4u6doje4a"  # REPLACE
db_license_model 				= "BRING_YOUR_OWN_LICENSE"



