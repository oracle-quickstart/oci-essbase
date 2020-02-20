# ![Essbase Logo](./images/oracle-Essbase.png) Oracle Essbase on Oracle Cloud Infrastructure

Oracle Essbase is a business analytics solution that uses a proven, flexible, best-in-class architecture for analysis, reporting, and collaboration. It delivers instant value and greater productivity for your business users, analysts, modelers, and decision-makers, across all lines of business within your organization. You can interact with Essbase, through a web or Microsoft Office interface, to analyze, model, collaborate, and report.

This Quick Start automates the deployment of Oracle Essbase instance on [Oracle Cloud Infrastructure (OCI)][oci]. It deploys additional stack components required – Autonomous Database, Load Balancer, Storage, Virtual Cloud Network (VCN) as part of the deployment.

## Getting Started

The repository contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack, that creates all the required resources and configures the application on the created resources. To simplify getting started, the Resource Manager Stack is created as part of each [release](https://github.com/oracle-quickstart/oci-essbase/releases)

### Encrypt Values using KMS

Oracle Cloud Infrastructure Key Management (KMS) enables you to manage sensitive information when creating a stack. You are required to use KMS to encrypt credentials during provisioning by creating a key. Passwords chosen for Essbase administrator and Database must meet the Resource Manager password requirements.

### Create Dynamic Group

You create dynamic groups of Oracle Cloud Infrastructure compute instances, and associate them with policies. For more information on dynamic groups, see [Managing Dynamic Groups](https://docs.cloud.oracle.com/iaas/Content/Identity/Tasks/managingdynamicgroups.htm).

### Setup Policies

Set up policies that are appropriate for your organization's security setup. The following is an example of a policy template, with each row being a policy statement.

```
Allow group group_name to manage orm-stacks in compartment compartment_name
Allow group group_name to manage orm-jobs in compartment compartment_name
Allow group group_name to manage virtual-network-family in compartment compartment_name
Allow group group_name to manage instances in compartment compartment_name
Allow group group_name to manage volume-family in compartment compartment_name
Allow group group_name to manage load-balancers in compartment compartment_name
Allow group group_name to manage buckets in compartment compartment_name
Allow group group_name to manage objects in compartment compartment_name
Allow group group_name to manage autonomous-database-family in compartment compartment_name
Allow group group_name to use instance-family in compartment compartment_name
Allow group group_name to manage autonomous-backups in compartment compartment_name
Allow group group_name to manage buckets in compartment compartment_name
Allow group group_name to manage vaults in compartment compartment_name
Allow group group_name to manage keys in compartment compartment_name
Allow group group_name to manage app-catalog-listing in compartment compartment_name
```

Some policies may be optional, depending on expected use. For example, if you're not using a load balancer, you don't need a policy that allows management of load balancers.

To allow instances within the compartment to invoke functionality without requiring further authentication, you must have group policies for the instances in the compartment. To do this, create a dynamic group, and set the policies for that dynamic group, such as shown in the following example:

```
Allow dynamic-group group_name to use autonomous-database in compartment compartment_name
Allow dynamic-group group_name to read buckets in compartment compartment_name
Allow dynamic-group group_name to manage objects in compartment compartment_name
Allow dynamic-group group_name to inspect volume-groups in compartment compartment_name
Allow dynamic-group group_name to manage volumes in compartment compartment_name
Allow dynamic-group group_name to manage volume-group-backups in compartment compartment_name
Allow dynamic-group group_name to manage volume-backups in compartment compartment_name
Allow dynamic-group group_name to manage autonomous-backups in compartment compartment_name
```


### Default Topology

![Default Topology Diagram](./images/image-default_topology.png)


### Full Topology

![Full Topology Diagram](./images/image-full_topology.png)

## License

### Bring Your Own License

Conversion Ratios: 
* For each supported Processor license You may activate up to 2 OCPUs of this BYOL offering.
* For Named User Plus licenses You may activate any supported compute shape provided the number of users is within licensed limits.

for more details refer: http://www.oracle.com/us/corporate/contracts/processor-core-factor-table-070634.pdf

Any of the following supported program licenses may be aggregated to meet the conversion ratio above.
* Business Intelligence Suite Foundation Edition; OR
* Oracle Business Intelligence Foundation Suite; OR
* Oracle Essbase Plus

### Universal Credits


## Questions

If you have an issue or a question, please take a look at our [FAQs](./FAQs.md) or [open an issue](https://github.com/oracle-quickstart/oci-essbase/issues/new).

[essbase]: https://docs.oracle.com/en/database/other-databases/essbase/index.html
[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[tf]: https://www.terraform.io
