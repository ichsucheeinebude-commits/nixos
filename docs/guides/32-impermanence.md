---
domain: 30
id: "NIXH-30-STO-003"
title: "Impermanence Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [storage,impermanence]
description: "Enable impermanence."
path: "docs/guides/GUIDE-32-impermanence.md"
links:
  module: "modules/30-storage/32-impermanence.nix"
---

# Guide: Impermanence Guide

```nix
my.storage.impermanence.enable = true;
```


---

## KB Nuggets

### Impermanence Setup
```nix
fileSystems."/".device = "none";
fileSystems."/".fsType = "tmpfs";
environment.persistence."/persist" = {
  directories = [ "/var/log" "/etc/ssh" ];
  files = [ "/etc/machine-id" ];
};
```

### ---

title: 🧹 Blank Snapshot Persistence (The Peak of Purity)
category: architecture/hygiene
status: [ACTIVE-SSoT]
capabilities: [root-rollback, btrfs-management, opt-in-persistence]
sources: [https://github.com/Misterio77/nix-config]
---

# 🧹 Blank Snapshot Persistence: "Erase your darlings"

Basierend auf den Patterns von Misterio77 führen wir die System-Hygiene auf das nächste Level.

### 🏛️ Das Prinzip

Anstatt nur Dateien zu löschen, wird das gesamte Root-Dateisystem (\`/\`) bei jedem Bootvorgang physisch durch einen leeren BTRFS-Snapshot ersetzt.

### 🛠️ Technische Umsetzung (BTRFS Workflow)

1.  **Boot-Phase:** Ein initrd-Script löscht das aktuelle root-Subvolume.
2.  **Rollback:** Ein leerer Snapshot (benannt \`blank\`) wird als neues \`root\` eingehängt.
3.  **Opt-in:** Nur Verzeichnisse, die wir in Nix deklarieren, werden nach \`/persist\` gemountet.

### 🚀 Der SRE-Vorteil

- **Garantierte Reinheit:** Es ist physisch unmöglich, dass sich Schadsoftware oder Konfigurations-Leichen im System verstecken.
- **Reproduzierbarkeit:** Wenn es nach dem Boot läuft, steht es in der Nix-Config. Wenn nicht, existiert es nicht.
