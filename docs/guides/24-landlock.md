---
domain: 20
id: "NIXH-20-SEC-004"
title: "Landlock Sandboxing Guide"
type: guide
status: draft
complexity: 3
reviewed: 2026-05-21
source: "guides/GUIDE-Landlock-Isolation-Mastery.md"
tags: [security,landlock,sandboxing,isolation]
description: "How to configure Landlock kernel-level isolation for services."
path: "docs/guides/24-landlock.md"
links:
  module: "modules/20-security/24-landlock.nix"
---

# Guide: Landlock Sandboxing

## Usage
```nix
my.security.landlock = {
  enable = true;
  enabledServices = [ "n8n" "my-worker-script" ];
  audit = true;  # Enable first to detect blocked paths
};
```

## What is Landlock?
Landlock is a Linux Security Module (LSM) that allows unprivileged processes to restrict their own filesystem access. Unlike AppArmor or SELinux (which require root configuration), Landlock can be used by individual services to self-sandbox.

## Why use it?
- **Near-zero overhead:** Kernel-native, almost no performance impact
- **Unprivileged:** Services can self-sandbox without root
- **Path traversal protection:** Even a compromised service cannot read SSH keys or configs not explicitly allowed
- **Defense-in-depth:** Complements systemd sandboxing and nftables

## Workflow
1. Enable with `audit = true` first — check `dmesg` for blocked access attempts
2. Add allowed paths via `ReadWritePaths` / `ReadOnlyPaths` in the service config
3. Once no legitimate access is blocked, disable audit mode for enforcement

## Kernel Requirement
Linux 5.13+ (all modern NixOS kernels support this).

## Integration with n8n / Automation
Landlock is most valuable for automation services (n8n, custom Python scripts) that process untrusted input. These services should only have access to their own data directories and `/tmp`.
