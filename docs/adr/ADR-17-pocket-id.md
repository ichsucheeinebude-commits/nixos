---
domain: 10
id: "NIXH-10-NET-008"
title: "Pocket-ID"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,oidc]
description: "Pocket-ID OIDC provider."
path: "docs/adr/ADR-17-pocket-id.md"
links:
  module: "modules/10-network/17-pocket-id.nix"
---

# ADR: Pocket-ID

## Decision
Self-hosted SSO via Pocket-ID.


---

## KB Nuggets

### Lightweight Identity: PocketID > Authentik
PocketID ist schlanker, OIDC-nativ, und perfekt für Homelab-Größen. Authentik ist Overkill für < 20 Users.
### Hybrid Identity Model
PocketID (OIDC) für Familie, mTLS für Admin-Dienste. Passkey-Only als langfristiges Ziel.

---
## PocketID Identity Provider (from KB)

# 🆔 [SERVICES]: Identity Provider (PocketID & Passkeys) (v4.2)

## 👤 1. USER LAYER (KISS)
"Oma-Logik": Wir schaffen Passwörter ab. Für deine Familie ist das Einloggen jetzt so einfach wie das Entsperren des Handys: Einmal kurz das Gesicht (FaceID) oder den Finger (TouchID) hinhalten, und sie sind in Jellyfin oder im Dashboard drin.
- **Problem:** Niemand kann sich 20 verschiedene Passwörter merken, und "Passwort vergessen" nervt alle.
- **Lösung:** Wir nutzen "PocketID". Das ist ein Programm, das sich um die Ausweise kümmert. Es nutzt "Passkeys" – das ist der neue, extrem sichere Standard von Apple und Google.
- **Vorteil:** Keine Passwörter mehr nötig. Einmal am Handy einrichten, danach geht alles automatisch.

---

## ⚙️ 2. TECHNICAL LAYER (AVIATION-GRADE)
Spezifikation des Identity Providers.

### 🔑 2.1 Passkeys & WebAuthn
- **PocketID:** Exklusiver Fokus auf Passkeys (WebAuthn). Keine Unterstützung für klassische Passwörter (Design-Entscheidung).
- **Gerätebindung:** Passkeys sind an die Hardware gebunden (TPM/Secure Enclave) oder werden via iCloud Keychain / Google Password Manager synchronisiert.
- **Multi-Device:** Ein User kann beliebig viele Passkeys (Handy, Laptop, Tablet) registrieren.

### ⚙️ 2.2 OIDC Integration
- **Generic OIDC:** PocketID wird als Identitätsprovider in Cloudflare Access eingebunden.
- **Native OIDC:** Jellyfin und Audiobookshelf unterstützen OIDC nativ. User werden direkt zu PocketID geleitet und nach dem biometrischen Scan wieder zurück zur App.
- **Souveränität:** Alle Benutzerdaten liegen lokal auf deinem Server, nicht bei Google oder Microsoft.

---

## 🧠 3. REASONING LAYER (HISTORY)
Architektonische Herleitung:
- **Wartungsarmut:** Das "Onboarding" für Familienmitglieder dauert unter 60 Sekunden (Registrierungslink öffnen -> biometrischer Scan -> fertig).
- **Phishing-Resistenz:** Passkeys können technisch nicht "gephished" werden, da sie kryptographisch an die Domain gebunden sind.
- **SSoT (Single Source of Truth):** Ein zentraler Ort (PocketID) verwaltet alle Zugänge. User sperren = sofortiger Zugriffsentzug für alle Dienste.

> [SOURCE-ENRICHMENT]: Extracted from `Claude-02 Homeserver mit Cloudflare sicher einrichten.md` (6.3.2026).

