# Proxmox Infrastructure Monorepo
**Living Infrastructure as Code (IaC) & Homelab Environment**

This repository is a living, continuously evolving record of my private server infrastructure (Proxmox VE). It is not a finalized software project, but an active monorepo reflecting the actual production, network, and tooling state of the `lubanhub.net` domain.

Due to the continuous development of the environment, this repository functions as an architectural roadmap. Each subdirectory represents an independent infrastructure module, deployed on the server using native system utilities. Detailed engineering decisions and technical documentation are located within the respective modules.

## Infrastructure Map (Modules)

* **[`/image-factory`](./image-factory)** A tooling pipeline based on shell scripts (Bash, `awk`, `sed`) and `cloud-init`. Handles the unattended, stateless provisioning of virtual machines utilizing a shared CoW backing store (Btrfs on ZFS).
* **[`/iam-sso`](./iam-sso)** *(WIP / Deploying)* Anonymized configuration templates for the Core Identity Management System. Defines edge authorization, LDAP directory structures, and Single Sign-On across the entire domain using HAProxy, Authelia, and OpenLDAP.
* **[`/services`](./services)** *(WIP / Deploying)* Sub-directory organizing deployment manifests and configuration templates for isolated user-facing workloads and applications (e.g., Nextcloud, Matrix) running behind the IAM perimeter.

## Deployment Philosophy (Template Hydration)
For strict security compliance, the codebase committed to this repository contains zero sensitive data. Deploying configurations to live LXC containers and virtual machines relies on read-only directory mapping (bind mounts) coupled with a Just-In-Time Template Hydration mechanism. 

Environmental abstraction is resolved exclusively at runtime: native utilities like `envsubst` parse the read-only raw templates, inject locally isolated secrets, and generate syntactically valid configuration artifacts immediately prior to the main service execution (e.g., via `ExecStartPre` hooks).