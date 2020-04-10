# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [19.3.0.0.3]

### Added
- Add security-util.sh script to register users with Essbase roles.

### Changed
- Provision private object storage bucket for storing temporary provisioning metadata to resolve some issues seen when using remote-exec operations.
- Use pre-built OCI image for bastion instances. This image is prebuilt with the configuration changes that were previously applied during the provisioning process.
- Revert change for whitelisting VCN for provisioned Autonomous Database. This resolves some intermittent issues that were seen preventing the compute node from properly access the database during provisioning.

### Noteworthy Image Changes
- Update base image to [Oracle-Linux-7.7-2020.02.21-0](https://docs.cloud.oracle.com/en-us/iaas/images/image/957e74db-0375-4918-b897-a8ce93753ad9/).
- Apply Essbase Cumulative Bundle Patch (30464311).

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

### Noteworthy Image Changes
- Update base image to [Oracle-Linux-7.7-2020.01.28-0](https://docs.cloud.oracle.com/en-us/iaas/images/image/0a72692a-bdbb-46fc-b17b-6e0a3fedeb23/).
- Update JDK to Oracle Java 8u241 - Server JRE.
- Apply WebLogic Patch Set Update January 2020 (30675853).
- Apply OPSS Patch Bundle October 2019 (30146350).

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

