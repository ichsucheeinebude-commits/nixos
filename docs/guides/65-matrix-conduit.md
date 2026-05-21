---
domain: 60
id: "NIXH-60-APP-006"
title: "Matrix Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,matrix]
description: "Configure Matrix."
path: "docs/guides/GUIDE-65-matrix-conduit.md"
links:
  module: "modules/60-apps/65-matrix-conduit.nix"
---

# Guide: Matrix Guide

Requires domain and subdomain set.


---

## KB Nuggets

=== Conduit Master-Config
SQLite/RocksDB-Backend. Federation: über Caddy. Media-Store auf Tier A. Backup: täglich.

---
## Conduit MASTER-CONFIG (from KB)

---
title: 🦀 Conduit Master-Config (Aviation-Grade Matrix)
category: architecture/communications
status: [ACTIVE-SSoT]
capabilities: [rust-performance, embedded-db, matrix-federation]
sources: [https://github.com/girlbossceo/conduit, NixOS Manual]
---

# 🦀 Conduit: Dein Matrix-Server in Rust

In mynixos ist Conduit der SSoT-Kommunikations-Server. Er ist hocheffizient und wartungsfrei.

## 🏛️ Architektur-Entscheidungen (Efficiency Standard)
1.  **Sprache:** Rust (Binary-Mandat erfüllt).
2.  **Datenbank:** Eingebettet (Sled). Keine externe PostgreSQL nötig (RAM-Ersparnis).
3.  **Sicherheit:** Läuft als \`DynamicUser\` mit minimalen Berechtigungen.

## ⚙️ Deklarative Nix-Konfiguration
Hier ist das Muster für deinen Dendriten (\`modules/30-services/matrix.nix\`):

\`\`\`nix
services.matrix-conduit = {
  enable = true;
  settings.global = {
    server_name = "m7c5.de";
    port = 6167;
    allow_registration = false; # Sicherheit geht vor!
    allow_federation = true;
    database_backend = "rocksdb"; # Oder standard sled
  };
};
\`\`\`

## 🛡️ SRE-Hardening
- **Port-Isolation:** Der Dienst hört nur auf \`127.0.0.1\`.
- **Ingress:** Caddy (Layer 20) übernimmt das TLS-Offloading und die \`/_matrix/\` Routen.
- **Secrets:** Das JWT-Secret wird via \`services.matrix-conduit.secretFile\` aus Sops eingebunden.

---
## Matrix Conduit Service (from KB)

---
title: "Service: Matrix-Conduit (Aviation-Grade Homeserver)"
category: "services"
tags: [communication, matrix, chat, rust, dendritic]
id: "NIXH-60-APP-005"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["60-apps/service-app-matrix-conduit.nix"]
---

# Service: Matrix-Conduit (Messenger Homeserver)

## 1. User Layer (KISS)
Matrix ist dein privater, sicherer Messenger – wie WhatsApp, nur dass der Server bei dir zu Hause steht. Conduit ist eine besonders schnelle und sparsame Version eines Matrix-Servers (geschrieben in Rust). Dieses Modul sorgt dafür, dass du mit anderen Matrix-Nutzern weltweit chatten kannst (Föderation), während alle deine Nachrichten sicher auf deinem Server gespeichert bleiben.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Performance
*   **Engine:** Conduit (Rust-basiert) via `services.matrix-conduit`.
*   **Datenbank:** Nutzt `rocksdb` für maximale Geschwindigkeit bei minimalem Ressourcenverbrauch.
*   **Ressourcen:** Begrenzt auf 1GB RAM (`MemoryMax`).

### Föderation & Ingress
*   **Domain:** Erreichbar über `matrix.nix.m7c5.de`.
*   **Discovery:** Automatische Konfiguration der `.well-known/matrix/server` und `client` Endpunkte in Caddy, damit andere Server deine Instanz finden können.
*   **Delegation:** Vollständige Unterstützung für verschlüsselte Kommunikation (E2EE).

### SRE Hardening & Security
*   **Sandboxing:** Nutzt die `mkService` Basis mit spezifischen Anpassungen für RocksDB.
*   **Isolation:** `StateDirectory = "matrix-conduit"`.
*   **No SSO:** Der Matrix-Server nutzt sein eigenes Identity-Management, um maximale Kompatibilität zu Matrix-Clients (Element, FluffyChat) zu gewährleisten.

### Integration (Nix-Snippet)
```nix
services.matrix-conduit = {
  enable = true;
  settings.global = {
    server_name = "matrix.nix.m7c5.de";
    database_backend = "rocksdb";
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-068] Conduit vs. Synapse
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Syna
