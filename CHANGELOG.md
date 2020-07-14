# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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
- [Oracle-Linux-7.8-2020.06.30-0](https://docs.cloud.oracle.com/en-us/iaas/images/image/0c6332bc-a5ec-4ddf-99b8-5f33b0bc461a/)
- Oracle Fusion Middleware 12.2.1.3.0 GA
- Oracle Essbase 19.3.0.0.0 GA
- Oracle JDK 8 update 251 Server JRE
- Applied patches:
  - 28186730 - OPatch 13.9.4.2.2 for FMW/WLS 12.2.1.3.0 and 12.2.1.4.0
  - 31101362 - NGInst SPU for 13.9.4.2.2 for jackson-databind update to 2.10.2
  - 30965714 - WebLogic Patch Set Update 12.2.1.3.200227 (ID:200227.1409)
  - 31030882 - Coherence 12.2.1.3.7 Cumulative Patch using OPatch
  - 30170398 - ADF Bundle Patch 12.2.1.3.200311 (ID:200311.2214.S)
  - 30146350 - OPSS Bundle Patch 12.2.1.3.191015
  - 30170398 - WebLogic Samples SPU 12.2.1.3.191015
  - 29650702 - FMW Platform 12.2.1.3.0 SPU April 2019
  - 30977621 - Essbase Cumulative Bundle Patch
  - 20623024 - RCU Patch
  - 29840258 - RCU Patch for invalid FMWREGISTRY password

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

