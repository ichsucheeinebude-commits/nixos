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
| `modules/` | Domain modules (00–90) |
| `users/` | Home-Manager user configs |
| `docs/adr/` | Architecture Decision Records |
| `docs/guides/` | Operational guides |
| `_templates/` | Blank templates for new docs |

## Domains

| Domain | Module | Purpose |
|--------|--------|---------|
| 00 | `00-core.nix` | Foundation: locale, nix-tuning, zram, boot-safeguard |
| 10 | `10-network.nix` | Network: DNS, Tailscale, interfaces |
| 20 | `20-security.nix` | Security: SSH hardening, nftables, AppArmor |
| 30 | `30-storage.nix` | Storage: ABC-tiering, mergerfs, ZFS |
| 40 | `40-monitoring.nix` | Monitoring: Netdata, Gatus, Scrutiny |
| 50 | `50-media.nix` | Media: Jellyfin, Arr-stack, QuickSync |
| 60 | `60-apps.nix` | Apps: Paperless, n8n, Vaultwarden |
| 70 | `70-forge.nix` | Forge: Forgejo, CI/CD |
| 80 | `80-gaming.nix` | Gaming: FHS game servers, AMP |
| 90 | `90-policy.nix` | Policies: Binary-only, security assertions |

## Conventions

- Every `.nix` file in `modules/` should have a NIXMETA header
- Every ADR in `docs/adr/` links to its guide and module
- Domain numbers are isomorphic: ADR-20 → Guide 20 → `20-security.nix`
- Secrets are managed via SOPS, stored encrypted in `secrets/`
