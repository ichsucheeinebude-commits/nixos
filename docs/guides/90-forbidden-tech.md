---
domain: 90
id: "NIXH-90-POL-001"
title: "Forbidden Tech Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
source: "architect-vision-v5"
tags: [policy,forbidden]
description: "Forbidden technology policy."
path: "docs/guides/GUIDE-90-forbidden-tech.md"
links:
  module: "modules/90-policy/90-forbidden-tech.nix"
---

# Guide: Forbidden Tech Guide

Set bastelmodus = true to relax during experiments.


---

## KB Nuggets

=== Docker-Ban Rationale
1. Reproducibility: Docker-Images sind nicht deklarativ.
2. Security: Container haben Root-Zugriff auf den Host.
3. Maintainability: nixpkgs-Pakete sind besser integriert.
4. Storage: Overlay-FS Konflikte mit ZFS.

---
## Findings Registry (from KB)

---
title: 🔍 FINDINGS-REGISTRY (The SRE Paper Trail)
category: architecture/traceability
status: [ACTIVE-LOG]
description: Physischer Nachweis aller dekonstruierten Quellen und extrahierten Nuggets.
---

# 🔍 Fundstellen-Datenbank: Der SRE Paper-Trail

Dieses Dokument listet alle externen Quellen auf, die für die Architektur von mynixos dekonstruiert wurden.

## 📅 Session: 2026-03-09 (The Mining Marathon)

### 🏗️ Infrastruktur & Core
- [**Caddy Official Docs**](https://caddyserver.com/docs/)
    - **Nugget:** API-Control via Port 2019 und JSON-Config Adapter.
- [**Nixpkgs: initrd-ssh.nix**](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/system/boot/initrd-ssh.nix)
    - **Nugget:** Remote LUKS Unlock für Headless-Server.
- [**Nixpkgs: nftables.nix**](https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/services/networking/nftables.nix)
    - **Nugget:** Build-time validation des Rulesets.

### 📊 Monitoring & Alerts
- [**TwiN/gatus**](https://github.com/TwiN/gatus)
    - **Nugget:** Native Matrix-Alerting Provider und YAML-first Config.
- [**r/Nix: njq Tool**](https://github.com/fadcreations/njq)
    - **Nugget:** JSON-Queries mit nativer Nix-Syntax.

### 🎬 Media & Storage
- [**advplyr/audiobookshelf**](https://github.com/advplyr/audiobookshelf)
    - **Nugget:** Native OIDC-Routen für PocketID Integration.
- [**jellyfin/jellyfin**](https://github.com/jellyfin/jellyfin)
    - **Nugget:** QuickSync Device-Mapping (/dev/dri/renderD128).
- [**deuxfleurs/garage**](https://github.com/deuxfleurs/garage)
    - **Nugget:** Rust-basierter S3-Speicher mit Metadaten/Daten-Trennung.

### 🛡️ Security & Policy
- [**numtide/srvos**](https://github.com/numtide/srvos)
    - **Nugget:** Standardisierte serviceConfig Hardening-Templates.
- [**r/Nix: Stable MAC Naming**](https://reddit.com/r/NixOS/comments/1rllpea/)
    - **Nugget:** systemd.link Bindung für persistente Interface-Namen.

## 🚀 SRE-Standard
Jede neue Quelle MUSS hier mit Datum und extrahiertem Nugget eing
