<p float="left">
  <img align="left" width="130" src="./images/oracle-Essbase.png">
  <br/>
  <h1>Variables</h1>
  <br/>
</p>


## OCI Variables

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| tenancy_ocid | Y | | OCID for the tenancy |
| user_ocid | Y | | OCID for the user | |
| fingerprint | Y | | PEM key fingerprint |
| private_key_path | Y | | Path to the private key that matches the fingerprint above |
| region | Y | | region in which to operate, example: us-ashburn-1, us-phoenix-1 |

## General Variables

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| compartment_ocid | Y | | OCID for the target compartment in which all created resources are created |
| service_name | N | | Provided name to prefix all created resources |

## KMS Variables 
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| kms_key_id | Y | | kms key OCID |
| kms_crypto_endpoint | Y | | http endpoint for the corresponding key |

## Network Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| use_existing_vcn | N | false | |
| existing_vcn_compartment_id | if `use_existing_vcn=true` | | vcn compartment OCID |
| existing_vcn_id | if `use_existing_vcn=true` | | vcn OCID |
| existing_application_subnet_compartment_id | if `use_existing_vcn=true` | | subnet compartment OCID |
| existing_application_subnet_id | if `use_existing_vcn=true` | | subnet OCID |
| existing_bastion_subnet_compartment_id | if `use_existing_vcn=true` | | subnet compartment OCID |
| existing_bastion_subnet_id | if `use_existing_vcn=true` | | subnet OCID |
| existing_load_balancer_subnet_compartment_id | Y, if `use_existing_vcn=true` | | subnet compartment OCID |
| existing_load_balancer_subnet_id | if `use_existing_vcn=true` | | subnet OCID |
| existing_load_balancer_subnet_id_2 | if `use_existing_vcn=true` | | subnet OCID |
| vcn_cidr | N | 10.0.0.0/16 | |
| application_subnet_cidr | N | 10.0.1.0/24 | |
| bastion_subnet_cidr | N | 10.0.3.0/24 | |
| load_balancer_subnet_cidr | N | 10.0.4.0/24 | |
| create_private_application_subnet | N | false | |

## Load Balancer Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| create_load_balancer | N | false | |
| load_balancer_shape | N | 100Mbps | |

## Bastion Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| bastion_instance_shape | N | VM.Standard.E2.1 | |

## Essbase instance details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| instance_shape | N | VM.Standard2.4 | |
| instance_availability_domain | Y | | Availability domain in region |
| ssh_public_key | Y | | Public key used on the instance |
| data_volume_size | N | 1024 | |
| config_volume_size | N | 512 | |
| essbase_admin_username | N | admin | |
| essbase_admin_password_encrypted | Y | | Password encrypted with provided KMS key |
| rcu_schema_prefix | N | | |
| assign_instance_public_ip | N | true | |

## Security Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| security_mode | N | idcs | | 
| idcs_client_tenant | if `security_mode=idcs` | | |
| idcs_client_id | if `security_mode=idcs` | | |
| idcs_client_secret_encrypted | if `security_mode=idcs` | | |
| idcs_external_admin_username | if `security_mode=idcs` | | |

## Database Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| use_existing_db | N | false | |
| existing_db_type | N | Autonomous Database | |
| existing_db_compartment_id | N | | database compartment OCID |
| existing_db_id | N | | autonomous database OCID |
| db_admin_password_encrypted | if `existing_db_type=Autonomous Database` | | Password encrypted with provided KMS key |
| db_license_model | N | LICENSE_INCLUDED | |
| existing_oci_db_system_id | N | | oci database OCID |
| existing_oci_db_system_dbhome_id | N | | oci database dbhome OCID |
| existing_oci_db_system_database_id | N | | oci database system OCID |
| existing_oci_db_system_database_pdb_name | N | | oci database PDB name |
| oci_db_admin_username | N | SYS | |
| oci_db_admin_password_encrypted | if `existing_db_type=OCI` | | Password encrypted with provided KMS key |
