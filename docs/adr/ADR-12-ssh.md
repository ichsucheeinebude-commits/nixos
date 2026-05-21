---
domain: 10
id: "NIXH-10-NET-003"
title: "SSH Server"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh]
description: "OpenSSH configuration."
path: "docs/adr/ADR-12-ssh.md"
links:
  module: "modules/10-network/12-ssh.nix"
---

# ADR: SSH Server

## Decision
Key-only auth, configurable port.


---

## KB Nuggets

### SSH ProxyJump Standard
Admin-Zugang via ProxyJump durch Cloudflare Tunnel. Kein direkter SSH-Port nach außen.
### Post-Quantum Crypto
`KEM algorithms: sntrup761x25519-sha512` für zukunftssichere SSH-Verschlüsselung.

### ---

title: 🔐 SSH Infrastructure Mastery (Advanced Core)
category: architecture/core
status: [ACTIVE-SSoT]
capabilities: [remote-luks-unlock, binary-cache-ssh, tmate-sharing, sshfs-integration]
sources: [nixpkgs/nixos/modules/system/boot/initrd-ssh.nix, nix-ssh-serve.nix]
---

# 🔐 SSH: Mehr als nur eine Shell

In mynixos nutzen wir SSH als das primäre Transport- und Kontroll-Layer für alle System-Operationen.

### 💎 1. Remote LUKS Unlock (Initrd SSH)

Für unseren headless Tower ist dies die wichtigste Sicherheits-Funktion.
- **Dienst:** \`boot.initrd.network.ssh.enable = true;\`
- **Nutzen:** Ermöglicht die Eingabe des Festplatten-Passworts via SSH, bevor das eigentliche System startet.
- **SRE-Security:** Nutzt dedizierte SSH-Keys, die nur im Boot-Vorgang existieren.

### 📦 2. Nix Binary Serving (\`nix-ssh-serve\`)

Der Tower agiert als privater Cache für andere Nix-Geräte im Haus.
- **Dienst:** \`services.nix-ssh-serve.enable = true;\`
- **Vorteil:** Schnelle Verteilung von Builds ohne Internet-Abhängigkeit.
