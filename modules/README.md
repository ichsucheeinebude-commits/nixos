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

| Modul | Domain | Zweck | Status |
|-------|--------|-------|--------|
| [00-core](00-core/) | 00 | Core: configs, ports, nix-tuning, zram, boot-safeguard, locale, shell-premium, symbiosis, lib-helpers, config-merger | ✅ 13 Module |
| [10-network](10-network/) | 10 | Network: firewall, ssh, blocky, caddy, dns, pocket-id, ddns, zigbee, adguard, tailscale, cloudflared, landing-zone, dns-map | ✅ 15 Module |
| [20-security](20-security/) | 20 | Security: fail2ban, kernel-hardening, secrets, landlock, clamav, secret-ingest | ✅ 6 Module |
| [30-storage](30-storage/) | 30 | Storage: ABC-Tiering, mergerfs, backup, impermanence, storage-policy, storage-mover | ✅ 5 Module |
| [40-monitoring](40-monitoring/) | 40 | Monitoring: Gatus, Netdata, ntfy, Scrutiny, Vector, Uptime Kuma | ✅ 6 Module |
| [50-media](50-media/) | 50 | Media: Jellyfin, Arr-Stack, QuickSync, *arr-suite, download, streaming | ✅ 10 Module |
| [60-apps](60-apps/) | 60 | Apps: Paperless, n8n, Vaultwarden, Home Assistant, Readeck, Matrix, Miniflux, Linkding, Monica, Karakeep, Linkwarden, OliveTin, Open WebUI | ✅ 13 Module |
| [70-forge](70-forge/) | 70 | Forge: Forgejo, Semaphore, Cockpit | ✅ 3 Module |
| [80-gaming](80-gaming/) | 80 | Gaming: FHS Game Server, AMP | ✅ 2 Module |
| [90-policy](90-policy/) | 90 | Policy: Forbidden Tech, Architecture Rules, Deferred Ops, Security Assertions, Binary-Only | ✅ 5 Module |

---

## 🔗 Verknüpfungen

- **ADRs:** `../docs/adr/` — WARUM wurde X gewählt?
- **Guides:** `../docs/guides/` — WIE wird es betrieben?
- **Hosts:** `../hosts/` — Welche Hosts importieren dieses Modul?
- **Template:** `../_templates/TPL_Nix_Module.nix`
