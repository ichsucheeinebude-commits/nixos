---
title: "Operational Guides"
status: active
---

# 📖 Guides — Operational Guides

> **Zweck:** Bedienung, Health-Checks und Troubleshooting pro Domain.

Jeder Guide hier beschreibt WIE ein Domain betrieben wird — nicht WARUM. Die Architektur-Rationale steht in der ADR.

---

## 📋 Regeln

- **Kein Nix-Code** → gehört ins Modul (`modules/`)
- **Keine Rationale** → gehört in die ADR (`docs/adr/`)
- **Health-Checks** müssen konkrete Befehle sein (keine Beschreibungen)
- **Troubleshooting** als Tabelle: Symptom → Cause → Fix
- **Frontmatter ist kanonisch** — `domain`, `id`, `status`, `complexity`, `links` sind Pflicht
- **Template:** `_templates/TPL_Guide.md`

---

## 🏗️ Struktur

| Datei | Domain | Zweck |
|-------|--------|-------|
| [00-core](00-core.md) | 00 | Core Foundation — Setup, Verification, Wartung |
| [10-network](10-network.md) | 10 | Network — DNS, Tailscale, Firewall-Regeln prüfen |
| [20-security](20-security.md) | 20 | Security — SSH, Firewall, Secrets rotieren |
| [30-storage](30-storage.md) | 30 | Storage — Tiering, ZFS, Backup verifizieren |
| [40-monitoring](40-monitoring.md) | 40 | Monitoring — Dashboards, Alerts, Logs |
| [50-media](50-media.md) | 50 | Media — Jellyfin, Arr-Suite, Transcoding |
| [60-apps](60-apps.md) | 60 | Apps — Paperless, n8n, Vaultwarden |
| [70-forge](70-forge.md) | 70 | Forge — Forgejo, Repos, CI-Pipelines |
| [80-gaming](80-gaming.md) | 80 | Gaming — Game Server, AMP |
| [90-policy](90-policy.md) | 90 | Policy — Compliance-Checks, Audits |

---

## 🔗 Verknüpfungen

- **ADRs:** `../adr/` — WARUM wurde X gewählt?
- **Module:** `../../modules/` — NixOS-Implementierung
- **Template:** `../../_templates/TPL_Guide.md`

---

## 📊 Status

| Metrik | Wert |
|--------|------|
| Guides gesamt | 10 |
| Aktiv | 0 |
| Draft | 10 |
| Verwaist | 0 |
