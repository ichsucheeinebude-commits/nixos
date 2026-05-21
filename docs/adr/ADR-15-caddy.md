---
domain: 10
id: "NIXH-10-NET-006"
title: "Caddy Reverse Proxy"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,caddy]
description: "Caddy as reverse proxy."
path: "docs/adr/ADR-15-caddy.md"
links:
  module: "modules/10-network/15-caddy.nix"
---

# ADR: Caddy Reverse Proxy

## Decision
Automatic TLS via ACME.


---

## KB Nuggets

### Caddy M1 Abrams — Reverse Proxy Mastery
Auto-TLS, Geoblock, SSO-Snippets. Orange Cloud (proxied) für App-Daten, Gray Cloud (DNS-only) für High-Bandwidth Medien.

### ---

title: 🛡️ Caddy M1 Abrams (Ingress Standard)
category: architecture/guides
status: [ACTIVE-SSoT]
sources: [adr/nixhome-architecture.md, modules/services/caddy.nix]
---

# 🛡️ Caddy M1 Abrams: Der Ingress-Standard

Wir nutzen Caddy als gehärteten Reverse-Proxy. Im Gegensatz zu Legacy-Ansätzen (Traefik) setzen wir auf native NixOS-Integration und Sops-Secrets.

### Kern-Konfiguration

- **DNS-01 Challenge:** Automatisierte Zertifikate via Cloudflare.
- **Forward-Auth:** Anbindung an PocketID (OIDC).
- **Hardening:** Strikte Systemd-Isolation.

Siehe: [adr/nixhome-architecture.md](../adr/nixhome-architecture.md)

### ---

title: "Caddy M1 Abrams: High-Security Gateway & mTLS"
category: "services"
tags: [nixos, caddy, mtls, security, cloudflare, h3, ech]
date: 2026-03-08
source: "architectural-legacy-v6.8"
status: "live-validated-v6.8-definitive"
---

# 🚀 [ADR-INFO]: CADDY GATEWAY (M1 ABRAMS EDITION V6.8)

Dieses Dokument definiert den ultimativen Sicherheitsstandard für das mynixos Proxy-Gateway. Es vereint modernste Verschlüsselung (HTTP/3, ECH) mit einer gehärteten mTLS-Infrastruktur.

---

### 🏗️ 1. USER LAYER: DER SICHERHEITS-SCHILD (KISS)

Dein Gateway ist wie ein Türsteher, der nicht nur nach dem Ausweis (Passwort) fragt, sondern auch prüft, ob das Gerät selbst (Smartphone/Laptop) vertrauenswürdig ist.
- **Vorteil:** Selbst wenn dein Passwort gestohlen wird, kommt niemand ohne dein mTLS-Zertifikat auf deine sensiblen Daten.
- **Einfachheit:** Einmal eingerichtet, merkst du nichts davon – die Verbindung steht einfach.

---

### A. Deklarative Härtung & Plugins

Um Cloudflare DNS-01 und mTLS zu nutzen, bauen wir Caddy mit spezifischen Modulen direkt in NixOS:
```nix
services.caddy = {
  enable = true;
  package = pkgs.caddy.withPlugins {
    plugins = [ "github.com/caddy-dns/cloudflare@latest" ];
  };
  globalConfig = 
    {
      protocols h1 h2 h3 # Enable HTTP/3
      # Encrypted Client Hello (ECH) für Meta-Privacy
      # ech
    }
  ;
};
```
