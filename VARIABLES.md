<p float="left">
  <img align="left" width="130" src="./images/oracle-Essbase.png">
  <br/>
  <h1>Variables</h1>
  <br/>
</p>

## OCI Variables

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| tenancy_ocid | Y | | The OCID for your tenancy |
| user_ocid | Y | | The OCID for the user | |
| fingerprint | Y | | PEM key fingerprint |
| private_key_path | Y | | Path to the private key that matches the fingerprint above |
| region | Y | | The region in which to create all resources. For example: us-ashburn-1, us-phoenix-1 |

## General Variables

| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| compartment_ocid | Y | | The target compartment OCID in which all provisioned resources will be created. |
| stack_display_name | N | | Display name prefix for all generated resources. If not specified, this will be automatically generated. |

## Notification Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| notification_topic_id | N | | The target notification topic OCID to send events. |

## Network Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| use_existing_vcn | N | false | Select this option to support deployment of Essbase components into an existing virtual cloud network (VCN). |
| existing_vcn_id | if `use_existing_vcn=true` | | An existing VCN in which to create the compute resources. |
| existing_application_subnet_id | if `use_existing_vcn=true` | | An existing subnet for the target Essbase instance. |
| existing_bastion_subnet_id | if `use_existing_vcn=true` | | An existing subnet for creating the bastion host |
| existing_load_balancer_subnet_id | if `use_existing_vcn=true` | | An existing subnet to use for the load balancer. |
| existing_load_balancer_subnet_id_2 | if `use_existing_vcn=true` | | An existing subnet to use for the second load balancer node. This field is required only if you are not using regional subnets. |
| vcn_cidr | N | 10.0.0.0/16 | The CIDR to assign to the new virtual cloud network (VCN) to create for this service. |
| vcn_dns_label | N | | The DNS label to assign to the VCN. If not provided, the value will be randomly generated. |
| application_subnet_cidr | N | 10.0.1.0/24 | The CIDR to assign to the subnet for the target Essbase compute node. This will be created as a regional subnet. |
| bastion_subnet_cidr | N | 10.0.3.0/24 | The CIDR to assign to the subnet for the bastion host. This will be created as a regional subnet. |
| load_balancer_subnet_cidr | N | 10.0.4.0/24 | The CIDR to assign to the subnet for the load balancer.  This will be created as regional subnet. |

## Load Balancer Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| create_load_balancer | N | false | Provision a load balancer in Oracle Cloud Infrastructure. The load balancer will be provisioned with a demo certificate. The use of demo certificate is not recommended for production workloads. |
| create_public_load_balancer | N | true | Provision the load balancer with a public IP address. |
| load_balancer_shape | N | 100Mbps | Select which load balancer shape. |

## Bastion Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| create_bastion | N | false | Create a bastion host. |
| bastion_instance_shape | if `create_bastion=true` | VM.Standard.E2.1 | The shape for the bastion compute instance. |
| bastion_availability_domain | if `create_bastion=true` | | The target availability domain for the bastion. |

## Essbase instance details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| instance_shape | N | VM.Standard2.4 | The shape for the Essbase compute instance. |
| instance_availability_domain | Y | | Availability domain in region |
| instance_hostname_label_prefix | N | | Prefix for the hostname label to which the compute instance will be assigned. If not provided, a randomly generated value will be used. |
| ssh_authorized_keys | Y | | Use the corresponding private key to access the Essbase compute instance. |
| data_volume_size | N | 1024 | Define the target size of the data volume, which stores the Essbase application data. |
| config_volume_size | N | 64 | Define the target size of the configuration volume, which stored the Essbase system data, such as logs. |
| temp_volume_size | N | 64 | Defined the target size of runtime temporary data. |
| essbase_admin_username | N | admin | The name of the Essbase system administrator. |
| essbase_admin_password_id | Y | | The OCID for the vault secret that holds the password for the Essbase system administrator. Use a password that starts with a letter, is between 8 and 30 characters long, contains at least one number, and, optionally, any number of the special characters (`$` `#` `_`). For example, `Ach1z0#d`. |
| rcu_schema_prefix | N | | Schema prefix to use when running RCU. A value with be automatically generated if not specified. |
| create_public_essbase_instance | N | false | Create the Essbase compute instance with a public IP address. |
| enable_essbase_monitoring | N | false | If enabled, the Essbase compute instance will emit telemetry data to the OCI Monitoring service. |
| enable_embedded_proxy | N | true | Expiremental: If disabled, the Essbase compute instance will not enable an Apache http proxy for IDCS integration. |

## Security Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| identity_provider | N | idcs | Choose embedded LDAP or integration with Identity Cloud Service (IDCS). The use of embedded LDAP is not recommended for production workloads. | 
| idcs_tenant | if `identity_provider=idcs` | | The ID of your Identity Cloud Service instance, which typically has the format idcs-<guid>, and is part of the host name that you use to access Identity Cloud Service. |
| idcs_client_id | if `identity_provider=idcs` | | The client ID for the IDCS application. |
| idcs_client_secret_id | if `identity_provider=idcs` | | The OCID for the vault secret that holds the client secret for the IDCS application. |
| idcs_external_admin_username | if `identity_provider=idcs` | | A user id to be registered as an Essbase administrator. This user must exist in the provided Identity Cloud Service instance. |

## Database Details
| Name | Required | Default | Description |
| ---- | -------- | ------- | ----------- |
| use_existing_db | N | false | Select this option to enable support of an existing database for the internal Essbase repository. |
| existing_db_type | N | Autonomous Database |  Select which database you will use |
| existing_db_id | N | | Target ATP database in which to create the Essbase schema. |
| db_admin_password_id | if `existing_db_type=Autonomous Database` | | The OCID for the vault secret that holds the password for the database administrator. Use a password that starts with a letter, is between 12 and 30 characters long, contains at least one number, and at least one of the special characters (`$` `#` `_`). For example, `BEstr0ng_#12`. |
| db_license_model | N | LICENSE_INCLUDED | |
| existing_oci_db_system_database_id | N | | The database within the DB System in which to create the Essbase schema. |
| existing_oci_db_system_database_pdb_name | N | | The name of the pdb in the target database. Required if not using the default pdb created during database provision. |
| oci_db_admin_username | N | SYS | The username for the database administrator. |
| oci_db_admin_password_id | if `existing_db_type=OCI` | | The OCID for the vault secret that holds the password for the database administrator. Use a password that starts with a letter, is between 12 and 30 characters long, contains at least one number, and at least one of the special characters (`$` `#` `_`). For example, `BEstr0ng_#12`. |
