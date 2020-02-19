# ![Essbase Logo](./images/oracle-Essbase.png) Oracle Essbase on Oracle Cloud Infrastructure

These are Terraform modules that deploy Oracle Essbase on [Oracle Cloud Infrastructure (OCI)][oci].

## Oracle Essbase

Oracle Essbase is a business analytics solution that uses a proven, flexible, best-in-class architecture for analysis, reporting, and collaboration. It delivers instant value and greater productivity for your business users, analysts, modelers, and decision-makers, across all lines of business within your organization. You can interact with Essbase, through a web or Microsoft Office interface, to analyze, model, collaborate, and report. Oracle Essbase on Marketplace uses the industry-standard Oracle Cloud Infrastructure.

This Quick Start automates the deployment of Oracle Essbase instance on OCI. It deploys additional stack components required – Autonomous Database, Load Balancer, Storage, Virtual Cloud Network (VCN) as part of the deployment.

## Getting Started with Essbase

The repository contains the application code as well as the [Terraform][tf] code to create a [Resource Manager][orm] stack, that creates all the required resources and configures the application on the created resources. To simplify getting started, the Resource Manager Stack is created as part of each [release](https://github.com/oracle-quickstart/oci-essbase/releases)

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

[oci]: https://cloud.oracle.com/en_US/cloud-infrastructure
[orm]: https://docs.cloud.oracle.com/iaas/Content/ResourceManager/Concepts/resourcemanager.htm
[tf]: https://www.terraform.io
