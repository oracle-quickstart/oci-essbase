# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [21.4.0.0.1]

### Changed
- Upgrade feature added. Customers can perform upgrade of 19.3.0.5.6+ and 21.3 instances to 21.4.0.0.1 latest release. A new Compute Instance will be created based on the previous installation. Please refer to documentation for details.
- Support for Secure Autonomous Database with private endpoint.
- Support for Catalog Storage in object storage bucket.

### Image Details

- [Oracle-Linux-7.9-2022.08.08-0](https://docs.oracle.com/en-us/iaas/images/image/0575b4f8-a914-4a74-898f-736225a30a00/)
- Oracle Fusion Middleware 12.2.1.4.0 GA
- Oracle Essbase 21.1.0.0.0 GA
- Oracle JDK 8 update 291 Server JRE
- Applied patches:
  - 28186730 - OPATCH latest patch
  - 31676526 - RCU Patches for ADWC Database
  - 30540494 - RCU Patches for ADWC Database
  - 30754186 - RCU Patches for ADWC Database
  - 34247006 - ADF BUNDLE PATCH 
  - 34373563 - WLS Stack Patch Bundle
  - 33727616 - Pre-requisite for log4j patch
  - 33735326 - Update log4j to 2.17
  - 33950717 - OPSS Bundle Patch
  - 33460488 - Essbase Release Update 21.4.0.0.0

## [21.3.0.0.1]

### Changed
- Remove creation of bastion. Customers are encouraged to use the OCI Bastion service for accessing their environment.
- Support for Terraform 1.0

### Image Details

- [Oracle-Linux-7.9-2021.08.27-0](https://docs.oracle.com/en-us/iaas/images/image/33995e8a-13e8-4ebe-8a27-8beae9e57043/)
- Oracle Fusion Middleware 12.2.1.4.0 GA
- Oracle Essbase 21.1.0.0.0 GA
- Oracle JDK 8 update 291 Server JRE
- Applied patches:
  - 33455144 - WebLogic Stack Patch Bundle 12.2.1.4.211011
  -	28186730 - OPatch 13.9.4.2.7 for FMW/WLS 12.2.1.3.0 and 12.2.1.4.0
  -	33416868 - WLS Patch Set Update 12.2.1.4.210930
  -	33286160 - Coherence 12.2.1.4 Cumulative Patch 11 (12.2.1.4.11)
  -	32148640 - WebLogic Samples SPU 12.2.1.4.210119
  -	31544353 - ADR for WebLogic Server 12.2.1.4.0
  -	32772437 - FMW platform 12.2.1.4.0 SPU Patch
  -	31676526 - RCU Patches for ADB
  -	30540494 - RCU Patches for ADB
  -	30754186 - RCU Patches for ADB
  -	32784652 - OPSS Bundle Patch 12.2.1.4.210418
  -	33313802 - ADF Bundle Patch 12.2.1.4.210903
  -	32646479 - Essbase Release Update 21.3.0.0.0
  -	33671996 - WebLogic overlay patch for October 2021 PSU for CVE-2021-44228 and CVE-2021-45046

## [21.2.0.0.1]

### Changed
- Enable failover support. Experimental.
- Use _tp connection type for Autonomous Transaction Processing (ATP) Database connections.
- Enable Analytic View Feature when using an Autonomous Data Warehouse Serverless database.
- Updated backup/restore functionality
  - Removed backup bucket for created Autonomous Database resource.
  - Created separate backup bucket for storing Essbase backup content.
- Migrate scripts to terrform 0.14 syntax

### Image Details
- [Oracle-Linux-7.9-2021.04.09-0](https://docs.oracle.com/en-us/iaas/images/image/8274a097-bc2b-46c7-ada3-dd138048c072/)
- Oracle Fusion Middleware 12.2.1.4.0 GA
- Oracle Essbase 21.1.0.0.0 GA
- Oracle JDK 8 update 291 Server JRE
- Applied patches:
  - 28186730 - OPatch 13.9.4.2.5 for FMW/WLS 12.2.1.3.0 and 12.2.1.4.0
  - 32253037 - WebLogic Patch Set Update 12.2.1.4.201209
  - 31544353 - ADR for WebLogic Server 12.2.1.4.0 July CPU 2020
  - 32124456 - Coherence 12.2.1.4.7 Cumulative Patch
  - 31676526 - RCU Patches for ADB
  - 30540494 - RCU Patches for ADB
  - 30754186 - RCU Patches for ADB
  - 31666198 - OPSS Bundle Patch 12.2.1.4.200724
  - 32357288 - ADF Bundle Patch 12.2.1.4.210107
  - 31949360 - Essbase Release Update 21.2.0.0.0


## [21.1.0.0.1]

### Changed
- Essbase 21.1 GA Release
- Fusion Middleware 12.2.1.4.0
- Migrate scripts to terraform 0.13 syntax.
- Switch from encrypted keys to secrets in vault.
- Support for flex compute shapes.
- Support for existing Autonomous Databases configured with private endpoint.
- Rename variable `security_mode` to `identity_provider`
- Disable bastion creation when using an existing network.
- Support selection of timezone for the compute instance.

### Image Details
- [Oracle-Linux-7.9-2021.01.12-0](https://docs.oracle.com/en-us/iaas/images/image/b6a7b057-03a8-4624-b08b-c12caa2c63a0/)
- Oracle Fusion Middleware 12.2.1.4.0 GA
- Oracle Essbase 21.1.0.0.0 GA
- Oracle JDK 8 update 281 Server JRE
- Applied patches:
  - 28186730 - OPatch 13.9.4.2.5 for FMW/WLS 12.2.1.3.0 and 12.2.1.4.0
  - 32253037 - WebLogic Patch Set Update 12.2.1.4.201209
  - 31544353 - ADR for WebLogic Server 12.2.1.4.0 July CPU 2020
  - 32124456 - Coherence 12.2.1.4.7 Cumulative Patch
  - 31676526 - RCU Patches for ADB
  - 30540494 - RCU Patches for ADB
  - 30754186 - RCU Patches for ADB
  - 31666198 - OPSS Bundle Patch 12.2.1.4.200724
  - 32357288 - ADF Bundle Patch 12.2.1.4.210107

## [19.3.0.3.4]

### Added
- Integration with Oracle Notification Service topic for Essbase lifecycle events.
- Integration with Oracle Monitoring Service for Essbase process and volume metrics collection.
- Support for private load balancer configuration for internal access.
- Support monitoring script to publish metrics to OCI Monitoring service for operational support.
- Added temp volume (default 64Gb) to store temporary runtime data. This does not participate in backup/restore lifecycle events.
  - Crash dump location updated to store under the temp volume.

### Changed
- Essbase stack configuration is started in the background using cloud-init.
  - Allows the remove of the SSH key pair used for provisioning.
  - Allows for bastion host to be an optional component.
- Reorganized the layout of the guided UI.
- Updated ssh public key input type to utilize the native control.
- Reduced default size of config volume to 64Gb.
- Support minimum size for the data volume at 256Gb.
- Support for changing the Essbase compute instance shape.
- Update bastion subscription to handle terms and conditions properly.
- Rename variable `mp_listing_id` to `essbase_listing_id`.
- Rename variable `mp_listing_resource_version` to `essbase_listing_resource_version`.
- Rename variable `mp_listing_resource_id` to `essbase_listing_resource_id`.
- Rename variable `service_name` to `stack_display_name` to reflect its role.
- Rename variable `idcs_client_tenant` to `idcs_tenant`.
- Rename variable `ssh_public_key` to `ssh_authorized_keys`.
- Support selection of availability domain for bastion host.
- Support specifying instance hostname prefix and network dns label to help with disaster-recovery use cases.
- Experimental: Support for flex compute shapes.
- Experimental: Support for disabling internal httpd proxy.

### Image Details
- [Oracle-Linux-7.8-2020.07.28-0](https://docs.cloud.oracle.com/en-us/iaas/images/image/229363c7-b01f-4b71-8c19-0661df7e16b5/)
- Oracle Fusion Middleware 12.2.1.3.0 GA
- Oracle Essbase 19.3.0.0.0 GA
- Oracle JDK 8 update 261 Server JRE
- Applied patches:
  - 28186730 - OPatch 13.9.4.2.4 for FMW/WLS 12.2.1.3.0 and 12.2.1.4.0
  - 30965714 - WebLogic Patch Set Update 12.2.1.3.200227
  - 31470751 - Coherence 12.2.1.3.10 Cumulative Patch using OPatch
  - 31532341 - ADF Bundle Patch 12.2.1.3.200623
  - 30146350 - OPSS Bundle Patch 12.2.1.3.191015
  - 29650702 - FMW Platform 12.2.1.3.0 SPU April 2019
  - 20623024 - RCU Patch
  - 29840258 - RCU Patch for invalid FMWREGISTRY password
  - 30977621 - Essbase 19.3.0.3.4 Cumulative Bundle Patch

## [19.3.0.2.3-1]

### Changed
- Fix subscription issue with bastion host creation. Caused by missing auto image agreement resource.

## [19.3.0.2.3]

### Changed
- Provision private object storage bucket for storing temporary provisioning metadata to resolve some issues seen when using remote-exec operations.
- Use pre-built OCI image for bastion instances. This image is prebuilt with the configuration changes that were previously applied during the provisioning process.
- Revert change for whitelisting VCN for provisioned Autonomous Database. This resolves some intermittent issues that were seen preventing the compute node from properly access the database during provisioning.

### Image Details
- [Oracle-Linux-7.7-2020.02.21-0](https://docs.cloud.oracle.com/en-us/iaas/images/image/957e74db-0375-4918-b897-a8ce93753ad9/)
- Oracle Fusion Middleware 12.2.1.3.0 GA
- Oracle Essbase 19.3.0.0.0 GA
- Oracle JDK 8 update 241 Server JRE
- Applied Patches:
  - 28186730
  - 30675853 - WebLogic Patch Set Update January 2020
  - 30146350 - OPSS Bundle Patch October 2019
  - 30464311 - Essbase Cumulative Bundle Patch
  - 29840258 - RCU Patch for invalid FMWREGISTRY password

## [19.3.0.0.2]

### Added
- Support OCI Database System as a target database.
- Support compartment selection for existing subnets.
- Output Essbase Redirect URL for the IDCS confidential app.
- Add freeform tag to created resources containing the display name prefix provided by user or generated.
- Essbase Universal Credits Model (UCM) edition information.

### Changed
- Migrate scripts to terraform 0.12 syntax.
- Enable access control for provisioned Autonomous Database instance and whitelist VCN.
- Add service gateway to the route table for the private application subnet.
- Make KMS encryption for sensitive input values mandatory.
- Remove "Use HTTPS" option. Load balancer will always be configured with HTTPS and a demo certificate.
- Enable SSL at Essbase compute instance. Endpoint will be configured with a demo certificate.
- Enable SSL for mid-tier connection to the ATP-D instance.
- Rename variable `create_private_subnet` to `create_private_application_subnet`
- Rename variable `assign_public_ip` to `assign_instance_public_ip`

### Image Details
- [Oracle-Linux-7.7-2020.01.28-0](https://docs.cloud.oracle.com/en-us/iaas/images/image/0a72692a-bdbb-46fc-b17b-6e0a3fedeb23/)
- Oracle Fusion Middleware 12.2.1.3.0 GA
- Oracle Essbase 19.3.0.0.0 GA
- Applied Patches
  - 28186730
  - 30675853 - WebLogic Patch Set Update January 2020
  - 30146350 - OPSS Bundle Patch October 2019
  - 29840258 - RCU Patch for invalid FMWREGISTRY password

## [19.3.0.0.1]
### Added
- Support for using existing ATP-D instance for Essbase RCU schema
- Support for bastion host shape selection

### Changed
- Updated terminology for IDCS attributes.
-- IDCS Tenant -> IDCS Instance GUID
-- IDCS Client ID -> IDCS Application Client ID
-- IDCS Client Secret -> IDCS Application Client Secret
- Fix Use HTTPS selection to show up when Provision Load Balancer is selected.
- Support Use Existing Database without requiring using an existing network.

### Image Details
- Oracle Fusion Middleware 12.2.1.3.0 GA
- Oracle Essbase 19.3.0.0.0 GA
- Applied Patches
  - 28186730
  - 29814665 - WebLogic Patch Set Update July 2019
  - 29680122 - OPSS Bundle Patch July 2019
  - 29135930 - XML Stream Patch
  - 29840258 - RCU Patch for invalid FMWREGISTRY password

## [19.3.0.0.0]

### Image Details
- Oracle Fusion Middleware 12.2.1.3.0 GA
- Oracle Essbase 19.3.0.0.0 GA
- Applied Patches
  - 28186730
  - 29814665 - WebLogic Patch Set Update July 2019
  - 29680122 - OPSS Bundle Patch July 2019

