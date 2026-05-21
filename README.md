# NixOS Configuration

Flake-based NixOS setup for Q958 (server) and laptop.

## Quick Start

```bash
nixos-rebuild switch --flake .#q958
nixos-rebuild switch --flake .#laptop
```

## Structure

| Path | Purpose |
|------|---------|
| `flake.nix` | Entry point |
| `hosts/` | Per-machine configurations |
| `modules/` | Domain modules (00–90, subdirectory-per-domain) |
| `users/` | Home-Manager user configs |
| `docs/adr/` | Architecture Decision Records |
| `docs/guides/` | Operational guides |
| `_templates/` | Blank templates for new docs |

## Domains

| Domain | Modules | Purpose |
|--------|---------|---------|
| 00 | `00-core/` (14 Module) | Core: configs, registry, nix-tuning, hardware, boot, tpm2, zram, locale, users, postgresql, shell-premium, symbiosis, lib-helpers, config-merger |
| 10 | `10-network/` (15 Module) | Network: firewall, SSH, blocky, caddy, dns-automation, pocket-id, ddns, zigbee, adguard, tailscale, cloudflared, landing-zone, dns-map |
| 20 | `20-security/` (7 Module) | Security: fail2ban, kernel-hardening, secrets, secrets-schema, landlock, clamav, secret-ingest |
| 30 | `30-storage/` (5 Module) | Storage: base, backup, impermanence, storage-policy, storage-mover |
| 40 | `40-monitoring/` (6 Module) | Monitoring: gatus, netdata, ntfy, scrutiny, vector, uptime-kuma |
| 50 | `50-media/` (10 Module) | Media: lib-media, arr-stack, download, streaming, discovery, jellyfin, sonarr, radarr, prowlarr, lidarr |
| 60 | `60-apps/` (13 Module) | Apps: paperless, n8n, vaultwarden, home-assistant, readeck, matrix, miniflux, linkding, monica, karakeep, linkwarden, olivetin, open-webui |
| 70 | `70-forge/` (3 Module) | Forge: forgejo, semaphore, cockpit |
| 80 | `80-gaming/` (2 Module) | Gaming: AMP, AMP-FHS |
| 90 | `90-policy/` (5 Module) | Policy: forbidden-tech, architecture-rules, deferred-ops, security-assertions, binary-only |

## Conventions

- Every `.nix` file in `modules/` has a `# ---NIXMETA` header
- Every ADR in `docs/adr/` links to its guide and module
- Isomorphic numbering: module `XX-name.nix` ↔ `ADR-XX-name.md` ↔ `XX-name.md`
- Secrets are managed via SOPS, stored encrypted in `secrets/`
