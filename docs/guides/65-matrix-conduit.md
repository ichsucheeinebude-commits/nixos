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
