---
domain: 60
id: "NIXH-60-APP-002"
title: "n8n Automation"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,n8n]
description: "n8n workflow automation."
path: "docs/adr/ADR-61-n8n.md"
links:
  module: "modules/60-apps/61-n8n.nix"
---

# ADR: n8n Automation

## Decision
Postgres-backed n8n instance.


---

## KB Nuggets

=== n8n Workflow-Automation
Self-hosted Automation-Plattform. PostgreSQL-Backend. OIDC-Auth via Pocket-ID.

---
## n8n Security Hardening (from KB)

---
title: "n8n Security Hardening: Secret Management"
category: "learnings"
tags: [n8n, security, sops, nixos, audit]
date: 2026-03-08
source: "github:grapefruit89/mynixos/30-automation/service-app-n8n.nix"
status: "verified-substance"
---

# 🧠 LEARNING: BEHEBUNG HARDCODIERTER SECRETS IN N8N

## 🔍 BEFUND (SRE-AUDIT)
Im Modul `service-app-n8n.nix` wurde ein hardcodierter Encryption-Key gefunden:
`N8N_ENCRYPTION_KEY = "gCXaCy//u9sm+lRK1cZPEb2KTxcCkW2O";`

> [ARCHITECT-NOTE]: Hardcodierte Keys in einem Git-Repository stellen ein hohes Sicherheitsrisiko dar (Credential Leak).

## 🛠️ LÖSUNG: INTEGRATION VIA SOPS-NIX

### 1. Secret in `secrets.yaml` hinzufügen
```yaml
n8n-encryption-key: "DEIN_SICHERER_KEY"
```

### 2. Anpassung des Nix-Moduls
Anstatt des Klartext-Strings nutzen wir den Pfad zum entschlüsselten Secret.

```nix
services.n8n = {
  enable = true;
  # [LIVE-ENRICHMENT]: n8n unterstützt das Laden von Variablen aus Dateien via environmentFile
};

systemd.services.n8n.serviceConfig.EnvironmentFile = config.sops.secrets.n8n-env.path;
```

> [LIVE-ENRICHMENT]: Da n8n unter `DynamicUser=true` läuft, muss sichergestellt werden, dass der n8n-Dienst Lesezugriff auf die SOPS-Datei in `/run/secrets/` hat. Dies wird am saubersten über `sops.secrets.n8n-env.owner = "n8n";` gelöst (sofern der User vorab bekannt ist) oder durch Verzicht auf `DynamicUser` zugunsten eines statischen Users.

## ✅ NÄCHSTE SCHRITTE
- [ ] Encryption-Key in SOPS überführen.
- [ ] Git-Historie bereinigen (falls der Key bereits gepusht wurde).

