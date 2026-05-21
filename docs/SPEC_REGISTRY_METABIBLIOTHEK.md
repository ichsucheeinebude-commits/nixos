# 🛰️ SPEC REGISTRY — Traceability Matrix

> **Purpose:** Central master source for domain-level traceability and upstream references.
> **Consolidated:** 10 domain ADRs + 10 domain guides (2026-05-21)

---

## 📚 Domain ADR Registry

| Domain | ADR | Guide | Modules | Purpose |
|--------|-----|-------|---------|---------|
| 00 | [ADR-00-core](../docs/adr/ADR-00-core.md) | [00-core](../docs/guides/00-core.md) | 14 | Core: principles, registry, tuning, hardware, boot, TPM2, ZRAM, locale, users, PostgreSQL, shell, symbiosis, lib-helpers, config-merger |
| 10 | [ADR-10-network](../docs/adr/ADR-10-network.md) | [10-network](../docs/guides/10-network.md) | 15 | Network: base, firewall, SSH, rescue, Blocky, Caddy, DNS automation, Pocket-ID, DDNS, Zigbee, AdGuardHome, Tailscale, Cloudflared, landing zone, DNS map |
| 20 | [ADR-20-security](../docs/adr/ADR-20-security.md) | [20-security](../docs/guides/20-security.md) | 7 | Security: fail2ban, kernel hardening, secrets, secrets-schema, Landlock, ClamAV, secret ingest |
| 30 | [ADR-30-storage](../docs/adr/ADR-30-storage.md) | [30-storage](../docs/guides/30-storage.md) | 5 | Storage: ABC tiering, backup, impermanence, storage policy, storage mover |
| 40 | [ADR-40-monitoring](../docs/adr/ADR-40-monitoring.md) | [40-monitoring](../docs/guides/40-monitoring.md) | 6 | Monitoring: Gatus, Netdata, ntfy, Scrutiny, Vector, Uptime Kuma |
| 50 | [ADR-50-media](../docs/adr/ADR-50-media.md) | [50-media](../docs/guides/50-media.md) | 10 | Media: lib-media, arr-stack, download, streaming, discovery, Jellyfin, Sonarr, Radarr, Prowlarr, Lidarr |
| 60 | [ADR-60-apps](../docs/adr/ADR-60-apps.md) | [60-apps](../docs/guides/60-apps.md) | 13 | Apps: Paperless, n8n, Vaultwarden, Home Assistant, Readeck, Matrix, Miniflux, Linkding, Monica, Karakeep, Linkwarden, OliveTin, Open WebUI |
| 70 | [ADR-70-forge](../docs/adr/ADR-70-forge.md) | [70-forge](../docs/guides/70-forge.md) | 3 | Forge: Forgejo, Semaphore, Cockpit |
| 80 | [ADR-80-gaming](../docs/adr/ADR-80-gaming.md) | [80-gaming](../docs/guides/80-gaming.md) | 2 | Gaming: AMP, AMP-FHS |
| 90 | [ADR-90-policy](../docs/adr/ADR-90-policy.md) | [90-policy](../docs/guides/90-policy.md) | 5 | Policy: forbidden tech, architecture rules, deferred ops, security assertions, binary-only |

---

## 🔧 Extracted Scripts

| Script | Purpose |
|--------|---------|
| `modules/00-core/scripts/mtls-generator.sh` | mTLS CA + client certificate generation |

---

## 📋 Additional Guides

| Guide | Purpose |
|-------|---------|
| [13-mtls-setup](../docs/guides/13-mtls-setup.md) | mTLS setup and certificate generation |

---

## 🔄 CI/CD Pipeline

| Workflow | Purpose |
|----------|---------|
| `.github/workflows/auto-docs.yml` | Auto-generate Mermaid diagrams and health reports on push |

---

## 📊 Consolidation Summary

**Previous:** ~80 individual ADRs + ~80 individual guides
**Current:** 10 domain ADRs + 10 domain guides + 1 additional guide (mtls-setup)
**Modules:** 80 Nix modules, all with updated NIXMETA links pointing to domain ADRs/guides

| Layer | Target Path | ADR | Guide |
|-------|-------------|-----|-------|
| 00-core | `modules/00-core/` | ADR-00-core.md | 00-core.md |
| 10-network | `modules/10-network/` | ADR-10-network.md | 10-network.md |
| 20-security | `modules/20-security/` | ADR-20-security.md | 20-security.md |
| 30-storage | `modules/30-storage/` | ADR-30-storage.md | 30-storage.md |
| 40-monitoring | `modules/40-monitoring/` | ADR-40-monitoring.md | 40-monitoring.md |
| 50-media | `modules/50-media/` | ADR-50-media.md | 50-media.md |
| 60-apps | `modules/60-apps/` | ADR-60-apps.md | 60-apps.md |
| 70-forge | `modules/70-forge/` | ADR-70-forge.md | 70-forge.md |
| 80-gaming | `modules/80-gaming/` | ADR-80-gaming.md | 80-gaming.md |
| 90-policy | `modules/90-policy/` | ADR-90-policy.md | 90-policy.md |
