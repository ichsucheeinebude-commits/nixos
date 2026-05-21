---
title: "NixOS Modules"
status: active
---

# 📖 modules — Domain Modules

> **Zweck:** Isomorphe NixOS-Module pro Domain (00–90). Ein Modul = eine Domain.

Jede `.nix`-Datei hier deklariert Optionen (`options.*`) und Implementierung (`config.*`) für einen funktionalen Bereich.

---

## 📋 Regeln

- **Jede Datei braucht einen kanonischen NIXMETA-Header** (`# ---NIXMETA ... # ---ENDNIXMETA`)
- **Isomorphe Nummerierung** — Domain 20 = `20-security.nix` = `ADR-20-security.md` = `20-security.md`
- **Keine Module ohne `lib.mkEnableOption`** — jedes Modul muss opt-in sein
- **Systemd-Hardening** ist Standard: `ProtectSystem=strict`, `PrivateTmp=true`, etc.
- **Template:** `_templates/TPL_Nix_Module.nix`

---

## 🏗️ Struktur

| Domain | ADR | Guide | Module | Zweck |
|--------|-----|-------|--------|-------|
| [00-core](00-core/) | [ADR-00](../docs/adr/ADR-00-core.md) | [Guide-00](../docs/guides/00-core.md) | 14 | Core: principles, registry, tuning, hardware, boot, TPM2, ZRAM, locale, users, PostgreSQL, shell, symbiosis, lib-helpers, config-merger |
| [10-network](10-network/) | [ADR-10](../docs/adr/ADR-10-network.md) | [Guide-10](../docs/guides/10-network.md) | 15 | Network: firewall, SSH, Blocky, Caddy, DNS, Pocket-ID, DDNS, Zigbee, AdGuard, Tailscale, Cloudflared, landing-zone, DNS-map |
| [20-security](20-security/) | [ADR-20](../docs/adr/ADR-20-security.md) | [Guide-20](../docs/guides/20-security.md) | 7 | Security: fail2ban, kernel-hardening, secrets, Landlock, ClamAV, secret-ingest |
| [30-storage](30-storage/) | [ADR-30](../docs/adr/ADR-30-storage.md) | [Guide-30](../docs/guides/30-storage.md) | 5 | Storage: ABC-Tiering, backup, impermanence, storage-policy, storage-mover |
| [40-monitoring](40-monitoring/) | [ADR-40](../docs/adr/ADR-40-monitoring.md) | [Guide-40](../docs/guides/40-monitoring.md) | 6 | Monitoring: Gatus, Netdata, ntfy, Scrutiny, Vector, Uptime Kuma |
| [50-media](50-media/) | [ADR-50](../docs/adr/ADR-50-media.md) | [Guide-50](../docs/guides/50-media.md) | 10 | Media: Jellyfin, Arr-Stack, Download, Streaming, Discovery, Sonarr, Radarr, Prowlarr, Lidarr |
| [60-apps](60-apps/) | [ADR-60](../docs/adr/ADR-60-apps.md) | [Guide-60](../docs/guides/60-apps.md) | 13 | Apps: Paperless, n8n, Vaultwarden, Home Assistant, Readeck, Matrix, Miniflux, Linkding, Monica, Karakeep, Linkwarden, OliveTin, Open WebUI |
| [70-forge](70-forge/) | [ADR-70](../docs/adr/ADR-70-forge.md) | [Guide-70](../docs/guides/70-forge.md) | 3 | Forge: Forgejo, Semaphore, Cockpit |
| [80-gaming](80-gaming/) | [ADR-80](../docs/adr/ADR-80-gaming.md) | [Guide-80](../docs/guides/80-gaming.md) | 2 | Gaming: AMP, AMP-FHS |
| [90-policy](90-policy/) | [ADR-90](../docs/adr/ADR-90-policy.md) | [Guide-90](../docs/guides/90-policy.md) | 5 | Policy: Forbidden Tech, Architecture Rules, Deferred Ops, Security Assertions, Binary-Only |

---

## 🔗 Verknüpfungen

- **Domain-ADRs:** `../docs/adr/ADR-XX-*.md` — Domain-weite Entscheidungen
- **Domain-Guides:** `../docs/guides/XX-*.md` — Domain-weite Betriebsanleitungen
- **Hosts:** `../hosts/` — Welche Hosts importieren diese Module?
- **Template:** `../_templates/TPL_Nix_Module.nix`
- **SPEC Registry:** `../docs/SPEC_REGISTRY_METABIBLIOTHEK.md`
