---
title: "Architecture Decision Records"
status: active
---

# 📖 ADRs — Architecture Decision Records

> **Zweck:** Architekturentscheidungen dokumentieren — WARUM, nicht WIE.

Jede ADR hier beantwortet eine konkrete Design-Entscheidung mit Context, Alternativen, Konsequenzen und Rollback-Plan.

---

## 📋 Regeln

- **Kein Nix-Code** → gehört ins Modul (`modules/`)
- **Keine Anleitungen** → gehört in den Guide (`docs/guides/`)
- **Jede ADR verlinkt** zu ihrem Guide und Modul (Frontmatter `links`)
- **Frontmatter ist kanonisch** — `domain`, `id`, `status`, `severity`, `review_after` sind Pflicht
- **Template:** `_templates/TPL_ADR.md`

---

## 🏗️ Struktur

| Datei | Domain | Zweck |
|-------|--------|-------|
| [ADR-00-core](ADR-00-core.md) | 00 | Core Foundation — Nix-Tuning, ZRAM, Boot-Safeguard |
| [ADR-10-network](ADR-10-network.md) | 10 | Network Configuration — DNS, Tailscale, Interfaces |
| [ADR-20-security](ADR-20-security.md) | 20 | Security Hardening — SSH, nftables, Kernel-Hardening |
| [ADR-30-storage](ADR-30-storage.md) | 30 | Storage Strategy — ABC-Tiering, ZFS, Backup |
| [ADR-40-monitoring](ADR-40-monitoring.md) | 40 | Monitoring — Netdata, Gatus, Scrutiny |
| [ADR-50-media](ADR-50-media.md) | 50 | Media Stack — Jellyfin, Arr-Suite, QuickSync |
| [ADR-60-apps](ADR-60-apps.md) | 60 | Applications — Paperless, n8n, Vaultwarden |
| [ADR-70-forge](ADR-70-forge.md) | 70 | Forge — Forgejo, CI/CD, Sovereign Git |
| [ADR-80-gaming](ADR-80-gaming.md) | 80 | Gaming — FHS Game Server, AMP |
| [ADR-90-policy](ADR-90-policy.md) | 90 | Security Policies — Binary-Only, Compliance |

---

## 🔗 Verknüpfungen

- **Guides:** `../guides/` — Bedienung und Health-Checks
- **Module:** `../../modules/` — NixOS-Implementierung
- **Template:** `../../_templates/TPL_ADR.md`

---

## 📊 Status

| Metrik | Wert |
|--------|------|
| ADRs gesamt | 10 |
| Akzeptiert | 0 |
| Draft | 10 |
| Review overdue | 0 |
