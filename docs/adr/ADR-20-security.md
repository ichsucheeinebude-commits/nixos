---
domain: 20
id: "NIXH-20-DOM-001"
title: "Domain 20 — Security Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 20
  - security
  - architecture
description: "Architectural decisions for the 20-security domain."
provides:
  - my.security.*
requires:
  - my.core.*
  - my.network.*
links:
  adr: docs/adr/ADR-20-security.md
  guide: docs/guides/20-security.md
---

# ADR-20: Domain Security Architecture

> Defense-in-depth: brute-force protection, kernel hardening, secrets management, filesystem isolation, and antivirus — all declarative in NixOS.

---

## Context

Domain 20 implements security layers that protect the system at every level: network (fail2ban), kernel (hardening + sysctl), secrets (SOPS encryption + schema), filesystem (Landlock LSM), and content scanning (ClamAV). Security assertions in Domain 90 enforce these policies at build time.

---

## Decisions

### 20-20: Fail2ban
**Decision:** NFTables backend for banning. Incremental banning (longer ban for repeat offenders). Caddy JSON log filter for HTTP-based detection.
**Rationale:** NFTables backend integrates with the existing firewall. Incremental banning is more effective than fixed bans. Caddy JSON filter catches web-level attacks.
**Alternatives considered:** iptables backend (rejected — conflicts with NFTables-only policy), CrowdSec (rejected — external dependency).

### 20-21: Kernel Hardening
**Decision:** Blacklist unused hardware modules for headless server. Enforce sysctl hardening: `kernel.panic = 10` (auto-reboot), `rp_filter = 1` (anti-spoofing), `accept_redirects = 0` (anti-MITM). `systemd-analyze security` target: < 4.0.
**Rationale:** Unused kernel modules are attack surface. Sysctl hardening prevents common network attacks. Auto-reboot after panic is essential for headless operation.
**Alternatives considered:** Default kernel config (rejected — unnecessary modules loaded).

### 20-22: Secrets Management
**Decision:** Age encryption via sops-nix. Declarative secrets. YAML/JSON/ENV support. Automatic template generation. No GPG (Age is simpler and more secure).
**Rationale:** SOPS-nix provides native NixOS integration with declarative secrets. Age keys are simpler than GPG. Secrets never appear in the Nix store.
**Alternatives considered:** git-crypt (rejected — GPG complexity), plain text (rejected — security violation), Vault (rejected — overkill for homelab).

### 20-23: Secrets Schema
**Decision:** Declarative schema for every secret: defined type (string, file, base64), target path, and permissions (0600, root:service).
**Rationale:** Schema ensures secrets are consistently structured and properly permissioned. Prevents misconfigured secrets from being deployed.
**Alternatives considered:** Ad-hoc secrets (rejected — inconsistent permissions, type confusion).

### 20-24: Landlock Sandboxing
**Decision:** Landlock LSM for per-service filesystem isolation. Combine with systemd sandboxing for defense-in-depth. Audit mode first to detect blocked paths before enforcement. Requires Linux 5.13+.
**Rationale:** Landlock allows unprivileged processes to self-restrict filesystem access — near-zero overhead, kernel-native. Protects against path traversal even if a service is compromised.
**Alternatives considered:** nsjail (rejected — heavyweight), AppArmor (rejected — root-level policy required).

### 20-25: ClamAV
**Decision:** Daemon + updater running permanently. Weekly scan (Saturday 03:00) of /home, /var/lib, /etc. Low CPU/IO priority (Weight=20, idle scheduling). Media directories (/mnt/media, downloads) excluded. MaxFileSize=50M, MaxScanSize=100M.
**Rationale:** Malware detection for files shared with Windows clients. Weekly (not daily) scans minimize performance impact. Resource limits prevent scan from impacting services.
**Alternatives considered:** Real-time scanning (rejected — too resource-heavy), no AV (rejected — shared files need protection).

### 20-26: Secret Ingest Pipeline
**Decision:** `systemd.path` watcher monitors `/etc/nixos/secret-landing-zone` for new files. One-shot service triggers Python processor for SOPS-encrypted files. Processed files moved to archive directory (audit trail).
**Rationale:** Automated secret processing eliminates manual SOPS commands. Audit trail via moved-to-processed directory. Python enables complex validation.
**Alternatives considered:** Manual SOPS operation (rejected — error-prone), inotify scripts (rejected — systemd.path is native).

---

## Consequences

### Positive
- Defense-in-depth across network, kernel, filesystem, and content layers
- Secrets never in plaintext on disk or in Nix store
- Automated secret processing with audit trail
- Kernel hardening reduces attack surface
- Landlock provides per-service filesystem isolation with near-zero overhead

### Negative
- ClamAV weekly scan causes disk I/O (mitigated by low priority scheduling)
- Landlock requires audit-mode tuning before enforcement
- SOPS key management adds operational complexity
- Fail2ban may produce false positives on aggressive blocklists

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 20-fail2ban.nix | Brute-force protection via NFTables |
| 21-kernel-hardening.nix | Module blacklist, sysctl hardening |
| 22-secrets.nix | SOPS/Age encrypted secrets management |
| 23-secrets-schema.nix | Declarative secret type/path/permission schema |
| 24-landlock.nix | Kernel-level filesystem isolation |
| 25-clamav.nix | Antivirus scanning (weekly, resource-limited) |
| 26-secret-ingest.nix | Automated SOPS file processing pipeline |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core), Domain 10 (network, NFTables)
- Used by: All service domains (require secrets, benefit from hardening)
