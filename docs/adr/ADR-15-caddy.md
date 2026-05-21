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

title: 🌐 Caddy Gateway Mastery (The Pro-Layer)
category: architecture/gateway
status: [ACTIVE-SSoT]
capabilities: [json-api-control, graceful-reloads, on-demand-tls, metrics-exporter]
sources: [Caddy Official Docs, Caddy GitHub, NixOS Module Audit]
---

# 🌐 Caddy: Das Gehirn deines Netzwerks

In mynixos verschmelzen wir die deklarative Power von Nix mit der dynamischen Agilität der Caddy-API.

### ⚡ 1. Zero-Downtime Updates (Graceful Reload)

Wir nutzen die nativen Caddy-Reload-Signale, um deine aktiven Streams (Jellyfin/Navidrome) bei Konfigurations-Updates zu schützen.
- **SRE-Vorteil:** Die Konfiguration wird atomar im Speicher getauscht. Kein Abbruch von HTTP-Sessions. ✅

### 💎 2. Die Admin-API (Monitoring & Control)

Caddy bietet eine mächtige REST-API auf Port 2019. Wir nutzen dies für Echtzeit-Einsichten.
- **Pattern:** Integration in Prometheus/Grafana für Layer 80 Monitoring.
- **SRE-Kontrolle:** Wir können Routen im Notfall über die API deaktivieren, ohne einen kompletten System-Rebuild abzuwarten.

### 🛡️ 3. On-Demand TLS (Dynamic SSL)

Caddy kann Zertifikate beim ersten Zugriff automatisch generieren.
- **Dienst:** \`on_demand_tls { ... }\` in den Global Options.
- **Vorteil:** Maximale Flexibilität für temporäre Test-Domains innerhalb deines m7c5.de Netzwerks. ✅

### 🏛️ 4. Native JSON-Injektion

Wo das Caddyfile an seine Grenzen stößt, injizieren wir direkt das hochperformante Caddy-JSON.
- **Anwendung:** Komplexe Filter für Layer 90-policy (z.B. Geo-Blocking oder mTLS-Verschachtelungen).

### ---

title: 🛡️ Caddy Operations Master-Config (Layer 20-server)
category: architecture/ingress
status: [ACTIVE-SSoT]
capabilities: [ingress-automation, zero-downtime, api-control, caddyfile-mastery]
sources: [https://caddyserver.com/docs/]
---

# 🛡️ Caddy Operations: Der mynixos Standard

Caddy ist das Herzstück deines Ingress-Layers. Wir nutzen die offizielle Philosophie für maximale Zuverlässigkeit.

### 🛠️ Der SRE-Workflow (CLI)

Wir nutzen diese Befehle zur Wartung:
1.  **Validierung:** \`caddy validate --config /etc/caddy/Caddyfile\` (Prüft Syntaxfehler).
2.  **Formatierung:** \`caddy fmt --overwrite /etc/caddy/Caddyfile\` (Garantierte Purity).
3.  **Trust:** \`caddy trust\` (Ermöglicht vertrauenswürdige interne HTTPS-Verbindungen).

### 📡 API-Interaktion

Für Live-Status-Abfragen nutzen wir den internen API-Endpunkt:
- **Status:** \`curl localhost:2019/config/\`
- **Reload:** \`curl -X POST \"http://localhost:2019/load\" -H \"Content-Type: application/json\" -d @config.json\`

### 🧩 Caddyfile Architektur (Dendritic Style)

Wir nutzen **Snippets**, um Redundanz zu vermeiden:
\`\`\`caddy
(pocket_id_auth) {
    forward_auth localhost:8080 {
        uri /api/oidc/auth
    }
}

# Anwendung im Dendriten
jellyfin.m7c5.de {
    import pocket_id_auth
    reverse_proxy localhost:8096
}
\`\`\`

### 🛡️ SRE-Hardening

- **Zero-Downtime:** Der \`reload\` Mechanismus von Caddy ist der Standard für alle mynixos-Updates.
- **Auto-HTTPS:** Wir verlassen uns auf die CertMagic-Engine (Kapitel 8).

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

### B. mTLS & SSO Snippets

Wir nutzen modulare Snippets zur Trennung von Sicherheits-Zonen:
```nix
# Zone: Hochsicher (mTLS zwingend)
(mtls_auth) {
  tls {
    client_auth {
      mode require_and_verify
      trusted_ca_cert_file /etc/nixos/secrets/mtls/ca.crt
    }
  }
}

# Zone: Standard (SSO via Pocket-ID)
(sso_auth) {
  forward_auth localhost:3000 {
    uri /api/auth/verify
    copy_headers X-Forwarded-User
  }
}
```

### C. Secret Management (Credential Isolation)

API-Tokens (Cloudflare) werden niemals im Nix-Store gespeichert.
- **Implementierung:** `systemd.services.caddy.serviceConfig.EnvironmentFile = "/run/secrets/caddy.env";`

---

### Warum HTTP/3 und ECH?

HTTP/3 verbessert die Performance in instabilen Netzwerken (z.B. Mobilfunk) massiv. **ECH (Encrypted Client Hello)** verhindert, dass der Internetprovider (ISP) sieht, welche Subdomain (z.B. `vault.m7c5.de`) du aufrufst – ein entscheidender Gewinn für die Privatsphäre.

### Warum mTLS vor dem Dashboard?

Das Dashboard (OliveTin/Homepage) ist die Schaltzentrale deines Servers. Ein Einbruch hier bedeutet die Kontrolle über das gesamte System. mTLS bietet eine physische Barriere, die rein softwarebasierte Angriffe (Exploits in der Web-App) ins Leere laufen lässt.

---

### 🧠 SRE-KONSEQUENZEN

- **Resilienz:** Durch `ProtectSystem=strict` und `MemoryDenyWriteExecute` ist der Proxy-Prozess immun gegen die meisten Remote-Code-Execution (RCE) Angriffe.
- **Wartung:** Die Erstellung neuer mTLS-Zertifikate erfolgt automatisiert via OliveTin IDP (siehe `services/knowledge_pipeline_scripts.md`).

### ---

title: "Cloudflare Homeserver Setup & Zero Trust"
category: "services"
tags: [cloudflare, tunnel, zero-trust, security, traefik]
date: 2026-03-08
source: "raw/_duplikate/Claude-Homeserver mit Cloudflare sicher einrichten (1).md"
status: "verified-substance"
---

# 🛡️ SERVICE: CLOUDFLARE ZERO TRUST INTEGRATION

Dokumentation der Absicherung des Fujitsu Q958 Heimservers ohne offene Ports am Router.

> **Verwandte Konzepte:** 
> - [NixHome Architecture](../adr/nixhome-architecture.md)
> - [Isomorphie-Strategie](../adr/isomorphie-strategie.md)

### 🏗️ ARCHITEKTUR-ÜBERSICHT

Der Zugriff von außen erfolgt ausschließlich über verschlüsselte Cloudflare Tunnels (Argo).

### Komponenten-Matrix

- **Host-IP:** `192.168.2.250`
- **Reverse-Proxy:** Traefik (Port 80, 443, 8183)
- **Identity Provider:** Cloudflare Access (Google / GitHub / Apple Integration)

### 🛠️ TECHNISCHE UMSETZUNG (CLOUDFLARED)

```nix
services.cloudflared = {
  enable = true;
  tunnels = {
    "q958-main" = {
      credentialsFile = "/run/secrets/cloudflared-creds";
      ingress = {
        "vault.m7c5.de" = "http://localhost:4743";
        "jellyfin.m7c5.de" = "http://172.18.0.5:8096"; # Direktes Container-Routing
      };
      default = "http_status:404";
    };
  };
};
```

> [ARCHITECT-NOTE]: Vermeide "Redirect Loops" (HTTP -> HTTPS -> Tunnel -> Traefik -> Tunnel). Das Tunnel-Routing sollte idealerweise direkt auf die Container-IPs oder den lokalen App-Port zeigen, um Traefik-Overhead für externe Zugriffe zu minimieren.

> [LIVE-ENRICHMENT]: Aktuelle Sicherheits-Empfehlungen von Cloudflare (2026) raten zur Nutzung von **Service Tokens** für die API-Kommunikation zwischen n8n und anderen Diensten über den Tunnel, um die Interaktive Authentifizierung (Login-Maske) für automatisierte Workflows zu umgehen.

### 🧠 SRE CHECKLISTE

- [x] Tunnel-Authentifizierung via SOPS-Secrets.
- [x] DNS-Resolver in Cloudflare auf `proxied` gestellt.
- [x] WAF-Regeln für Geoblocking (Nur DE/EU erlauben).

---

### 📈 VIII. KUMULATIVE VEREDELUNG (BATCH 2)

> [SEARCH-ENRICHMENT]: Das Setup von **Cloudflare Access** als Gatekeeper vor **Pocket-ID** erlaubt eine zentrale Autorisierung. In der CF Zero Trust Console wird Pocket-ID als "Generic OIDC Provider" registriert. Dies ermöglicht Single-Sign-On (SSO) für alle proxied Dienste.

> [ARCHITECT-NOTE]: Die Trennung in **Orange Cloud** (Apps) und **Gray Cloud** (Media) ist essenziell. 
> - **Gray Cloud (DNS-only):** Für `jellyfin.m7c5.de`. Erfordert in Traefik eine `ipAllowList` Middleware oder die Nutzung von Tailscale, da die IP-Adresse physisch exponiert ist.
> - **Orange Cloud (Proxied):** Für `vault.m7c5.de`. Nutzt Cloudflare WAF und CDN-Caching.

> [TECHNICAL-DETAIL]: Das Onboarding der Familie erfolgt via **Passkeys**. Pocket-ID generiert einmalige Invite-Links. Nach der Registrierung (FaceID/TouchID) ist der Zugang für alle OIDC-fähigen Dienste (Jellyfin, ABS, Seerr) ohne Passwort-Eingabe aktiv.
