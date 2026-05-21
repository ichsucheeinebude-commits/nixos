---
domain: 00
id: "NIXH-00-DOM-001"
title: "Domain 00 — Core Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 00
  - core
  - operations
description: "Operational guide for the 00-core domain."
links:
  adr: ADR-00-core.md
  guide: 00-core.md
---

# 00-core: Domain Core Guide

> Operational procedures for the foundational core layer — master toggles, registry, tuning, hardware, boot, and shared services.

---

## Prerequisites

- NixOS installed on target hardware
- Flake-enabled Nix installation
- `den` framework available in flake inputs

---

## Module Operations (ODR-sorted)

### 00-00: Principles & Defaults
**Enable:** `my.core.principles.enable = true;` (default). Set `my.core.principles.bastelmodus = true;` for development mode.
**Verify:** `nixos-rebuild switch` succeeds. Check `systemctl list-units` for core services.
**Troubleshooting:** If bastelmodus causes unexpected behavior, set to false and rebuild.

### 00-01: Configs & Registry (SSoT)
**Enable:** Edit `configs.nix` with identity, hardware specs, network config. All modules read from `config.my.core.*`.
**Verify:** `nix eval .#nixosConfigurations.<host>.config.my.core` returns expected values.
**Troubleshooting:** Missing registry values cause module evaluation errors — check `configs.nix` completeness.

### 00-02: Nix Tuning
**Enable:** Enabled by default. Check `/etc/nix/nix.conf` for settings.
**Verify:** `nix store gc --dry-run` shows reclaimable space. `nix store optimise --dry-run` shows optimisable paths.
**Troubleshooting:** If GC doesn't run, check the weekly timer: `systemctl list-timers nix-gc`.

### 00-03: Hardware Profile
**Enable:** Set `my.core.hardware.cpuType = "intel";` and GPU options in host config.
**Verify:** `dmesg | grep microcode` shows microcode loaded. `vainfo` shows GPU capabilities.
**Troubleshooting:** Missing microcode — check CPU detection in symbiosis module.

### 00-04: Boot Safeguards
**Enable:** Enabled by default. Adjust `boot.loader.systemd-boot.configurationLimit` if needed.
**Verify:** `bootctl list` shows limited generations. Check /boot free space: `df -h /boot`.
**Troubleshooting:** Boot partition full — manually remove old generations: `nix-env --delete-generations old`.

### 00-05: TPM2 Sealing
**Enable:** `my.core.tpm2.enable = true;` (off by default). Requires TPM2 hardware.
**Verify:** `tpm2_pcrread` shows PCR values. `systemd-cryptenroll --list` shows TPM2 key.
**Troubleshooting:** TPM2 not detected — check BIOS settings. FIDO2 fallback available.

### 00-06: ZRAM Swap
**Enable:** Enabled by default. Check `cat /proc/swaps` for zram device.
**Verify:** `zramctl` shows compression stats. `free -h` shows swap usage.
**Troubleshooting:** If zram not active, check `systemctl status systemd-zram-setup@zram0`.

### 00-07: Locale & System
**Enable:** Host must set `time.timeZone`, `i18n.defaultLocale`, `console.keyMap`.
**Verify:** `timedatectl` shows timezone. `locale` shows locale settings.
**Troubleshooting:** Wrong timezone — check host config overrides module defaults.

### 00-08: Users & Groups
**Enable:** Define users in module. Personal config in `users/<name>/`.
**Verify:** `getent passwd <user>` shows user. `id <user>` shows groups (including GID 169 for media).
**Troubleshooting:** Missing media access — verify GID 169 assignment.

### 00-09: PostgreSQL
**Enable:** `my.core.postgresql.enable = true;`
**Verify:** `systemctl status postgresql`. `psql -U postgres -c "SELECT version();"`
**Troubleshooting:** Connection refused — check `pg_hba.conf` and listen_addresses.

### 00-10: Shell Premium
**Enable:** Enabled by default. Custom MOTD appears on SSH login.
**Verify:** SSH login shows fastfetch output. `eza --version` confirms replacement tools.
**Troubleshooting:** MOTD not showing — check `sshd_config` for `PrintMotd yes`.

### 00-11: Symbiosis
**Enable:** Auto-detects CPU. Run `nixhome-detect-hw` for hardware info.
**Verify:** `nixhome-detect-hw` shows CPU vendor, RAM, hardware profile age.
**Troubleshooting:** Wrong CPU detected — manually override `cpuType` in host config.

### 00-12: Service Helpers Library
**Enable:** Use `lib.mkService { name = "myapp"; port = 8080; ... }` in service modules.
**Verify:** Generated systemd unit: `systemctl cat <service>`. Caddy vhost: `caddy list-modules`.
**Troubleshooting:** Service not starting — check generated unit file for errors.

### 00-13: Config Merger
**Enable:** Edit `/var/lib/nixhome/user-config.json` for runtime overrides. Run `nixhome-apply`.
**Verify:** `cat /run/nixhome/config.json` shows merged config. Check service reload logs.
**Troubleshooting:** Overrides not applied — verify JSON syntax. Check tmpfs mount at /run.

---

## Cross-Domain Interactions

- Provides: `my.core.*` options consumed by all other domains
- Depends on: Nothing (foundation layer)
