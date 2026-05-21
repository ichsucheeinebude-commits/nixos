---
domain: 20
id: "NIXH-20-DOM-001"
title: "Domain 20 — Security Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 20
  - security
  - operations
description: "Operational guide for the 20-security domain."
links:
  adr: ADR-20-security.md
  guide: 20-security.md
---

# 20-security: Domain Security Guide

> Operational procedures for fail2ban, kernel hardening, secrets management, Landlock isolation, ClamAV, and secret ingest.

---

## Prerequisites

- Domain 00 (core) deployed
- Domain 10 (network, NFTables) active
- SOPS/Age keys generated and configured
- Linux 5.13+ (for Landlock)

---

## Module Operations (ODR-sorted)

### 20-20: Fail2ban
**Enable:** `my.security.fail2ban.enable = true;` Configure jails for SSH, Caddy, and other services.
**Verify:** `fail2ban-client status` shows active jails. `fail2ban-client status sshd` shows banned IPs.
**Troubleshooting:** Jail not triggering — check log path in jail config. False positives — increase `maxretry` or `findtime`.

### 20-21: Kernel Hardening
**Enable:** Enabled by default. Check `sysctl -a | grep <param>` for applied settings.
**Verify:** `systemd-analyze security` shows score (target: < 4.0). `lsmod` shows blacklisted modules not loaded.
**Troubleshooting:** Hardware not working — a blacklisted module may be needed. Remove from blacklist and rebuild.

### 20-22: Secrets Management
**Enable:** Generate Age key: `age-keygen -o /etc/nixos/secrets/age.key`. Add public key to `.sops.yaml`. Encrypt: `sops -e -i secrets.yaml`.
**Verify:** `sops -d secrets.yaml` decrypts successfully. Check `/run/secrets/` for deployed secrets.
**Troubleshooting:** Decryption fails — verify Age key matches public key in `.sops.yaml`. Secret not in /run — check sops-nix config.

### 20-23: Secrets Schema
**Enable:** Define schema in module options: `{ name, type, path, mode, owner, group }`.
**Verify:** `ls -la /run/secrets/` shows correct permissions (0600, root:service).
**Troubleshooting:** Wrong permissions — check schema definition. Secret type mismatch — verify type matches expected format.

### 20-24: Landlock Sandboxing
**Enable:** `my.security.landlock.enable = true;` Start with audit mode: `my.security.landlock.mode = "audit";`
**Verify:** Check `dmesg | grep landlock` for audit violations. Switch to enforcement after tuning: `mode = "enforce";`
**Troubleshooting:** Service broken in enforce mode — switch back to audit, check blocked paths, add to allowlist.

### 20-25: ClamAV
**Enable:** `my.security.clamav.enable = true;` Configure scan paths and exclusions.
**Verify:** `systemctl status clamav-daemon`. `systemctl status clamav-freshclam` shows signature updates. Check scan logs: `journalctl -u clamav-scan`.
**Troubleshooting:** High CPU during scan — reduce CPUWeight. False positives — add to exclusion list.

### 20-26: Secret Ingest Pipeline
**Enable:** Drop SOPS-encrypted files into `/etc/nixos/secret-landing-zone/`. Watcher auto-triggers processing.
**Verify:** `systemctl status secret-ingest.path` shows active watcher. Check `/etc/nixos/secret-landing-zone/processed/` for processed files.
**Troubleshooting:** File not processed — check SOPS encryption. Verify Age key is available. Check service logs.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core), Domain 10 (network, NFTables)
- Used by: All service domains (secrets, hardening)
