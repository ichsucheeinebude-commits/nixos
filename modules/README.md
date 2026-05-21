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
| [00-core.nix](00-core.nix) | 00 | Core Foundation: configs, ports, nix-tuning, zram, boot-safeguard | ✅ Implementiert |
| [10-network.nix](10-network.nix) | 10 | Network: DNS, Tailscale, Firewall-Regeln | ✅ Implementiert |
| [20-security.nix](20-security.nix) | 20 | Security: SSH Hardening, nftables, AppArmor | ✅ Implementiert |
| [30-storage.nix](30-storage.nix) | 30 | Storage: ABC-Tiering, ZFS, Backup | ⏳ TODO |
| [40-monitoring.nix](40-monitoring.nix) | 40 | Monitoring: Netdata, Gatus, Scrutiny | ⏳ TODO |
| [50-media.nix](50-media.nix) | 50 | Media: Jellyfin, Arr-Suite, QuickSync | ⏳ TODO |
| [60-apps.nix](60-apps.nix) | 60 | Apps: Paperless, n8n, Vaultwarden | ⏳ TODO |
| [70-forge.nix](70-forge.nix) | 70 | Forge: Forgejo, CI/CD | ⏳ TODO |
| [80-gaming.nix](80-gaming.nix) | 80 | Gaming: FHS Game Server, AMP | ⏳ TODO |
| [90-policy.nix](90-policy.nix) | 90 | Policy: Binary-Only, Compliance | ⏳ TODO |

---

## 🔗 Verknüpfungen

- **ADRs:** `../docs/adr/` — WARUM wurde X gewählt?
- **Guides:** `../docs/guides/` — WIE wird es betrieben?
- **Hosts:** `../hosts/` — Welche Hosts importieren dieses Modul?
- **Template:** `../_templates/TPL_Nix_Module.nix`
