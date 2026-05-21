---
domain: 90
id: "NIXH-90-POL-002"
title: "Architecture Rules"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [policy,architecture]
description: "Architecture guard rails."
path: "docs/adr/ADR-91-architecture-rules.md"
links:
  module: "modules/90-policy/91-architecture-rules.nix"
---

# ADR: Architecture Rules

## Decision
Build-time assertions prevent architectural drift.


---

## KB Nuggets

=== Architecture Evolution Strategy
Von Monolith zu Dendritic. Jeder Schritt ist reversibel. Feature-Oriented statt Class-Oriented.
=== Flake Parts Architecture
Auto-Import via import-tree. Deferred Modules für Konflikt-Minimierung. No specialArgs needed.

---
## SRE Audit v4.2 Findings (from KB)

# 🧠 [LEARNINGS]: SRE Code Review & Hardening-Roadmap (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Dein System ist mächtig, hat aber momentan gefährliche Sicherheitslücken. Wir stellen es von "alles ist standardmäßig an" auf "Aviation-Grade" um – also so sicher wie ein Flugzeug-Cockpit.
- **Problem:** Momentan sind zu viele Dienste standardmäßig aktiv (registry.nix) und es gibt "Zeitbomben" wie Passwort-Login beim Booten.
- **Lösung:** Wir isolieren jeden Dienst, verstecken Passwörter sicher und sorgen dafür, dass das System nur das tut, was es wirklich soll.
- **Ziel:** Ein unzerstörbares, vorhersagbares NixOS-System, das auf jeder Hardware (Intel/ARM) läuft.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Detaillierte Spezifikation der identifizierten Schwachstellen und Gegenmaßnahmen.

### 🛑 2.1 Identifizierte "Zeitbomben" (Critical Findings)
1.  **Registry-Monolith:** `registry.nix` aktiviert 50+ Services via `lib.mkDefault true`. Führt zu Konfigurations-Drift und Sicherheitsrisiken durch ungenutzte, aber aktive Dienste.
2.  **SSH-Rescue Lücke:** `ssh-rescue.nix` öffnet Passwort-Authentifizierung für 5 Minuten nach jedem Boot. Klassisches Ziel für Race-Condition-Angriffe.
3.  **Plaintext Secrets:** `service-app-n8n.nix` enthält hardcodierte Encryption Keys im Nix-Store.
4.  **mTLS-Integrität:** P12-Zertifikate werden ohne Passwort öffentlich über Caddy bereitgestellt.
5.  **Netzwerk-Stack:** Fehlende sysctl-Härtung (ICMP Redirects, Source Route Acceptance) ermöglicht MITM-Angriffe im LAN.

### 🛠️ 2.2 Hardening Roadmap
- **HAL (Hardware Abstraction Layer):** Einführung von `00-core/hal.nix`, um Hardware-Abhängigkeiten (Intel/AMD/ARM) von den Diensten zu entkoppeln.
- **True Isomorphy:** Umstieg von `chunker.py` auf `nix eval` zur Metadaten-Extraktion (Single Source of Truth).
- **Service-Isolation:** Einsatz von `nftables` Micro-Segmentation (skuid-basiert) und `systemd` Sandboxing-Profilen (`mkHardenedService`).
- **Impermanence:** Umstellung auf `tmpfs` as Root, um Konfigurations-Drift physisch zu unterbinden.
- **Storage Broker (ABC-Tiering):** Zentrale Verwaltung von NVMe (Tier A), SSD (Tier B) und HDD (Tier C) via `hal-storage.nix`.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung: Warum dieser massive Umbau?
- **SRE Audit v4.2:** Das System ist aus seiner "Homelab-Experimentier-Phase" herausgewachsen. Die Komplexität von 50+ Diensten lässt sich nicht mehr manuell beherrschen.
- **Aviation-Grade Anspruch:** Um echte Hochverfügba

---
## Top NixOS Community Projects (from best-of-nix)


<a href="#contents"><img align="right" width="15" height="15" src="https://git.io/JtehR" alt="Back to top"></a>

_Reusable NixOS modules for extending system functionality_

<details><summary><b><a href="https://github.com/nix-community/home-manager">Home Manager</a></b> (🥇27 ·  ⭐ 9K) - Manage your user configuration just like NixOS. <code><a href="http://bit.ly/34MBwT8">MIT</a></code></summary>

- [GitHub](https://github.com/nix-community/home-manager) (👨‍💻 1.5K · 🔀 2.2K · 📋 2.9K - 22% open · ⏱️ 14.12.2025)
</details>
<details><summary><b><a href="https://github.com/nix-community/NixOS-WSL">NixOS-WSL</a></b> (🥇26 ·  ⭐ 2.6K) - Modules for running NixOS on the Windows Subsystem for Linux. <code><a href="http://bit.ly/3nYMfla">Apache-2</a></code></summary>

- [GitHub](https://github.com/nix-community/NixOS-WSL) (👨‍💻 46 · 🔀 150 · 📥 65K · 📋 250 - 15% open · ⏱️ 13.12.2025)
</details>
<details><summary><b><a href="https://github.com/NixOS/nixos-hardware">nixos-hardware</a></b> (🥇23 ·  ⭐ 2.8K) - A collection of NixOS modules covering hardware quirks. <code><a href="https://tldrlegal.com/search?q=CC0-1.0">❗️CC0-1.0</a></code></summary>

- [GitHub](https://github.com/NixOS/nixos-hardware) (👨‍💻 500 · 🔀 820 · 📥 1.6K · 📋 400 - 42% open · ⏱️ 29.11.2025)
</details>
<details><summary><b><a href="https://github.com/nix-darwin/nix-darwin">nix-darwin</a></b> (🥇21 ·  ⭐ 4.8K) - Manage macOS configuration just like on NixOS. <code><a href="http://bit.ly/34MBwT8">MIT</a></code></summary>

- [GitHub](https://github.com/nix-darwin/nix-darwin) (👨‍💻 270 · 🔀 560 · 📋 790 - 36% open · ⏱️ 14.12.2025)
</details>
<details><summary><b><a href="https://github.com/fort-nix/nix-bitcoin">nix-bitcoin</a></b> (🥇21 ·  ⭐ 590) - Modules and packages for Bitcoin nodes with higher-layer protocols with an emphasis on security. <code><a href="http://bit.ly/34MBwT8">MIT</a></code></summary>

- [GitHub](https://github.com/fort-nix/nix-bitcoin) (👨‍💻 31 · 🔀 120 · 📥 8.2K · 📋 210 - 16% open · ⏱️ 24.11.2025)
</detail
