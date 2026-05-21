---
domain: 20
id: "NIXH-20-SEC-002"
title: "Kernel Hardening"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [security,kernel]
description: "Kernel module blacklist + sysctl."
path: "docs/adr/ADR-21-kernel-hardening.md"
links:
  module: "modules/20-security/21-kernel-hardening.nix"
---

# ADR: Kernel Hardening

## Decision
Blacklist unused hardware, enforce sysctl hardening.


---

## KB Nuggets

### Kernel-Surgical Diet
Blackliste unnötige Module für Headless-Server. `systemd-analyze security` Ziel: < 4.0.

---
## KB Nuggets

### ---

title: 🛡️ Kernel Mastery & Hardening (Layer 00-core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [kernel-selection, sysctl-hardening, intel-microcode, zfs-compatibility]
sources: [nixpkgs/nixos/modules/system/boot/kernel.nix, hardened profile]
---

# 🛡️ Der mynixos Kernel-Standard

In mynixos folgen wir dem Prinzip der "Maximum Stability & Purity". Der Kernel ist das Herzstück unserer SRE-Strategie.

### 🏛️ 1. Kernel-Wahl (Stability vs. Features)

Für den Tower nutzen wir den **LTS-Kernel** oder den **Hardened-Kernel**.
- **Dienst:** \`boot.kernelPackages = pkgs.linuxPackages_hardened;\`
- **Vorteil:** Maximale Sicherheit gegen Zero-Day-Exploits.
- **Wichtig:** Wir prüfen immer die ZFS-Kompatibilität (ADR-006).

### 🛡️ 2. Sysctl Hardening (Network & Panic)

Wir zementieren die Sicherheits-Parameter direkt im Kernel-Laufzeit-Modul.
\`\`\`nix
boot.kernel.sysctl = {
  # Automatischer Reboot nach 10 Sek. bei Kernel Panic (Headless Pflicht!)
  "kernel.panic" = 10;
  # Schutz vor IP-Spoofing
  "net.ipv4.conf.all.rp_filter" = 1;
  # Deaktiviere ICMP Redirects (Schutz vor MITM)
  "net.ipv4.conf.all.accept_redirects" = 0;
  "net.ipv4.conf.all.send_redirects" = 0;
};
\`\`\`

### 💎 3. Intel-Microcode (Security-Fixes)

Wir erzwingen die neuesten Microcode-Patches für den i3-9100.
- **Dienst:** \`hardware.cpu.intel.updateMicrocode = true;\`

