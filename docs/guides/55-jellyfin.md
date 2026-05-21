---
domain: 50
id: "NIXH-50-MED-006"
title: "Jellyfin Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,jellyfin]
description: "Configure Jellyfin."
path: "docs/guides/GUIDE-55-jellyfin.md"
links:
  module: "modules/50-media/55-jellyfin.nix"
---

# Guide: Jellyfin Guide

Enable gpuAcceleration for Intel GPUs.


---

## KB Nuggets

=== Jellyfin Setup
VA-API Transcoding. Transcode-Dir auf Tier B (SSD). Library-Dirs auf Tier C (HDD, readonly).

---
## QuickSync Configuration (from KB)

---
title: ⚡ Intel QuickSync & iGPU (NixOS-Native Standard)
category: architecture/hardware
status: [ACTIVE-SSoT]
capabilities: [hardware-transcoding, quicksync, vaapi, energy-efficiency]
sources: [https://perfectmediaserver.com/02-tech-stack/nixos/, ironicbadger blog]
---

# ⚡ Intel QuickSync: Der Transcoding-Standard

Für den Fujitsu Q958 (Intel UHD 630) ist QuickSync der "Heilige Gral". Wir erreichen 4K-Transcoding bei minimalem Stromverbrauch (~35W).

## 🛡️ SRE-Entscheidung: Host-Native statt VM-GVT-g
Wir verzichten auf GVT-g (GPU-Slicing), da es in der Praxis zu Instabilitäten führt. Stattdessen nutzen wir direktes Hardware-Rendering auf dem NixOS-Host oder innerhalb nativer Dienste.

## ⚙️ NixOS Hardware-Konfiguration
Um die iGPU für Dienste wie Jellyfin oder Plex verfügbar zu machen, deklarieren wir:

\`\`\`nix
hardware.graphics = {
  enable = true;
  extraPackages = with pkgs; [
    intel-media-driver # iHD Treiber für UHD 630
    vaapiIntel         # VA-API Support
    libvdpau-va-gl
  ];
};
\`\`\`

## 🧩 Berechtigungs-Management (Layer 00-core)
Dienste, die auf die iGPU zugreifen, müssen in der Gruppe \`render\` oder \`video\` sein:
\`\`\`nix
users.users.jellyfin.extraGroups = [ "render" "video" ];
\`\`\`

## 🚀 Monitoring
Wir nutzen \`intel-gpu-tools\`, um die Auslastung der iGPU live zu überwachen:
- Befehl: \`intel_gpu_top\`
