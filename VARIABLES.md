<p float="left">
  <img align="left" width="130" src="./images/oracle-Essbase.png">
  <br/>
  <h1>Variables</h1>
  <br/>
</p>


## OCI Variables

| Name | Default | Description |
| ---- | ------- | ----------- |
| tenancy_ocid | | OCID for the tenancy |
| user_ocid | | OCID for the user | |
| fingerprint | | PEM key fingerprint |
| private_key_path | | Path to the private key that matches the fingerprint above |
| region | | region in which to operate, example: us-ashburn-1, us-phoenix-1 |

## General Variables

| Name | Default | Description |
| ---- | ------- | ----------- |
| compartment_ocid | | OCID for the target compartment in which all created resources are created |
| service_name | | Provided name to prefix all created resources |

## KMS Variables 
| Name | Default | Description |
| ---- | ------- | ----------- |
| kms_key_id | | kms key OCID |
| kms_crypto_endpoint | | http endpoint for the corresponding key |

## Network Details
| Name | Default | Description |
| ---- | ------- | ----------- |
| use_existing_vcn | false | |
| existing_vcn_compartment_id | | vcn compartment OCID |
| existing_vcn_id | | vcn OCID |
| existing_application_subnet_compartment_id | | subnet compartment OCID |
| existing_application_subnet_id | | subnet OCID |
| existing_bastion_subnet_compartment_id | | subnet compartment OCID |
| existing_bastion_subnet_id | | subnet OCID |
| existing_load_balancer_subnet_compartment_id | | subnet compartment OCID |
| existing_load_balancer_subnet_id | | subnet OCID |
| existing_load_balancer_subnet_id_2 | | subnet OCID |
| vcn_cidr | 10.0.0.0/16 | |
| application_subnet_cidr | 10.0.1.0/24 | |
| bastion_subnet_cidr | 10.0.3.0/24 | |
| load_balancer_subnet_cidr | 10.0.4.0/24 | |
| create_private_application_subnet | false | |

## Load Balancer Details
| Name | Default | Description |
| ---- | ------- | ----------- |
| create_load_balancer | false | |
| load_balancer_shape | 100Mbps | |

## Bastion Details
| Name | Default | Description |
| ---- | ------- | ----------- |
| bastion_instance_shape | VM.Standard.E2.1 | |

## Essbase instance details
| Name | Default | Description |
| ---- | ------- | ----------- |
| instance_shape | VM.Standard2.4 | |
| instance_availability_domain | | Availability domain in region |
| ssh_public_key | | Public key used on the instance |
| data_volume_size | 1024 | |
| config_volume_size | 512 | |
| essbase_admin_username | admin | |
| essbase_admin_password_encrypted | | Password encrypted with provided KMS key |
| rcu_schema_prefix | | |
| assign_instance_public_ip | true | |

## Security Details
| Name | Default | Description |
| ---- | ------- | ----------- |
| security_mode | idcs | | 
| idcs_client_tenant | | |
| idcs_client_id | | |
| idcs_client_secret_encrypted | | |
| idcs_external_admin_username | | |

## Database Details
| Name | Default | Description |
| ---- | ------- | ----------- |
| use_existing_db | false | |
| existing_db_type | Autonomous Database | |
| existing_db_compartment_id | | database compartment OCID |
| existing_db_id | | autonomous database OCID |
| db_admin_password_encrypted | | Password encrypted with provided KMS key |
| db_license_model | LICENSE_INCLUDED | |
| existing_oci_db_system_id | | oci database OCID |
| existing_oci_db_system_dbhome_id | | oci database dbhome OCID |
| existing_oci_db_system_database_id | | oci database system OCID |
| existing_oci_db_system_database_pdb_name | | oci database PDB name |
| oci_db_admin_username | SYS | |
| oci_db_admin_password_encrypted | | Password encrypted with provided KMS key |
| existing_db_connect_string | | database connection string |
