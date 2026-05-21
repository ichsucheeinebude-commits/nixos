# 🛰️ SPEC REGISTRY — Traceability Matrix

> **Purpose:** Central master source for module traceability and upstream references.
> **Source:** Extracted from grapefruit89/mynixos (MetaBibliothek NMS v2.3/v4.x)

---

## 🧬 Traceability Matrix — New Modules (MetaBibliothek Extraction)

| ID | Nix Module | ADR | Guide | Upstream Reference |
|---|---|---|---|---|
| NIXH-00-COR-029 | `modules/00-core/10-shell-premium.nix` | [ADR-10](../docs/adr/ADR-10-shell-premium.md) | [Guide-10](../docs/guides/10-shell-premium.md) | [ryan4yin/nix-config](https://github.com/ryan4yin/nix-config/tree/main/modules/nixos/base/shell) |
| NIXH-00-COR-033 | `modules/00-core/11-symbiosis.nix` | *pending* | *pending* | [NixOS Hardware](https://github.com/NixOS/nixos-hardware) |
| NIXH-10-NET-010 | `modules/10-network/20-adguardhome.nix` | [ADR-20](../docs/adr/ADR-20-adguardhome.md) | [Guide-20](../docs/guides/20-adguardhome.md) | [NixOS: adguardhome](https://nixos.org/manual/nixos/stable/#opt-services.adguardhome.enable) |
| NIXH-10-NET-011 | `modules/10-network/21-tailscale.nix` | [ADR-21](../docs/adr/ADR-21-tailscale.md) | [Guide-21](../docs/guides/21-tailscale.md) | [tailscale/tailscale](https://github.com/tailscale/tailscale) |
| NIXH-20-SEC-010 | `modules/20-security/25-clamav.nix` | [ADR-25](../docs/adr/ADR-25-clamav.md) | [Guide-25](../docs/guides/25-clamav.md) | [NixOS: clamav](https://nixos.org/manual/nixos/stable/#opt-services.clamav.daemon.enable) |
| NIXH-20-SEC-011 | `modules/20-security/26-secret-ingest.nix` | [ADR-26](../docs/adr/ADR-26-secret-ingest.md) | [Guide-26](../docs/guides/26-secret-ingest.md) | [Mic92/sops-nix](https://github.com/Mic92/sops-nix) |
| NIXH-60-APP-020 | `modules/60-apps/70-linkwarden.nix` | [ADR-70](../docs/adr/ADR-70-linkwarden.md) | [Guide-70](../docs/guides/70-linkwarden.md) | [linkwarden/linkwarden](https://github.com/linkwarden/linkwarden) |
| NIXH-60-APP-021 | `modules/60-apps/71-olivetin.nix` | [ADR-71](../docs/adr/ADR-71-olivetin.md) | [Guide-71](../docs/guides/71-olivetin.md) | [OliveTin/OliveTin](https://github.com/OliveTin/OliveTin) |
| NIXH-90-POL-003 | `modules/90-policy/93-security-assertions.nix` | [ADR-93](../docs/adr/ADR-93-security-assertions.md) | [Guide-93](../docs/guides/93-security-assertions.md) | [NixOS: assertions](https://nixos.org/manual/nixos/stable/#opt-assertions) |
| NIXH-00-COR-007 | `modules/00-core/13-config-merger.nix` | [ADR-13](../docs/adr/ADR-13-config-merger.md) | [Guide-13](../docs/guides/13-config-merger.md) | [jq](https://jqlang.github.io/jq/) |
| NIXH-00-COR-003e | `modules/00-core/07-locale-system.nix` | *Enhanced* | *Enhanced* | Auto-detect from source `auto-locale.nix` |
| NIXH-90-POL-004 | `modules/90-policy/94-binary-only.nix` | [ADR-94](../docs/adr/ADR-94-binary-only.md) | [Guide-94](../docs/guides/94-binary-only.md) | [NixOS: max-jobs](https://nixos.org/manual/nixos/stable/#opt-nix.settings.max-jobs) |
| NIXH-10-GTW-003 | `modules/10-network/22-cloudflared-tunnel.nix` | [ADR-22](../docs/adr/ADR-22-cloudflared-tunnel.md) | [Guide-22](../docs/guides/22-cloudflared-tunnel.md) | [Cloudflare Tunnels](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/) |
| NIXH-60-APP-022 | `modules/60-apps/72-open-webui.nix` | [ADR-72](../docs/adr/ADR-72-open-webui.md) | [Guide-72](../docs/guides/72-open-webui.md) | [open-webui/open-webui](https://github.com/open-webui/open-webui) |
| NIXH-10-GTW-008 | `modules/10-network/23-landing-zone-ui.nix` | *pending* | *pending* | [Caddy root](https://caddyserver.com/docs/caddyfile/directives/root) |
| NIXH-10-GTW-006b | `modules/10-network/24-dns-map.nix` | *pending* | *pending* | [NixOS: hosts](https://nixos.org/manual/nixos/stable/#opt-networking.hosts) |
| NIXH-00-COR-019 | `modules/00-core/12-lib-helpers.nix` | *pending* | *pending* | [NixOS: systemd](https://nixos.org/manual/nixos/stable/#opt-systemd.services) |

---

## 🔧 Extracted Scripts

| Script | Purpose |
|--------|---------|
| `modules/00-core/scripts/mtls-generator.sh` | mTLS CA + client certificate generation |

---

## 🔄 CI/CD Pipeline

| Workflow | Purpose |
|----------|---------|
| `.github/workflows/auto-docs.yml` | Auto-generate Mermaid diagrams and health reports on push |

---

## 📊 Extraction Summary

**Source:** `grapefruit89/mynixos` (MetaBibliothek NMS v2.3/v4.x)
**Target:** `ichsucheeinebude-commits/nixos` (10-domain isomorphic structure)

| Layer | Source Path | Target Path | Status |
|-------|------------|-------------|--------|
| 00-core | `shell-premium.nix` | `modules/00-core/10-shell-premium.nix` | ✅ Injected |
| 00-core | `symbiosis.nix` | `modules/00-core/11-symbiosis.nix` | ✅ Injected |
| 00-core | `scripts/mtls-generator.sh` | `modules/00-core/scripts/mtls-generator.sh` | ✅ Injected |
| 10-gateway | `adguardhome.nix` | `modules/10-network/20-adguardhome.nix` | ✅ Injected |
| 10-gateway | `tailscale.nix` | `modules/10-network/21-tailscale.nix` | ✅ Injected |
| 20-infra | `clamav.nix` | `modules/20-security/25-clamav.nix` | ✅ Injected |
| 20-infra | `secret-ingest.nix` | `modules/20-security/26-secret-ingest.nix` | ✅ Injected |
| 50-knowledge | `service-app-linkwarden.nix` | `modules/60-apps/70-linkwarden.nix` | ✅ Injected |
| 30-automation | `service-app-olivetin.nix` | `modules/60-apps/71-olivetin.nix` | ✅ Injected |
| 00-core | `lib-helpers.nix` | `modules/00-core/12-lib-helpers.nix` | ✅ Injected |
| 90-policy | `security-assertions.nix` | `modules/90-policy/93-security-assertions.nix` | ✅ Injected |
| 90-policy | `binary-only.nix` | `modules/90-policy/94-binary-only.nix` | ✅ Injected |
| 10-gateway | `cloudflared-tunnel.nix` | `modules/10-network/22-cloudflared-tunnel.nix` | ✅ Injected |
| 10-gateway | `landing-zone-ui.nix` | `modules/10-network/23-landing-zone-ui.nix` | ✅ Injected |
| 10-gateway | `dns-map.nix` | `modules/10-network/24-dns-map.nix` | ✅ Injected |
| .legacy_folders/20-automation | `service-app-open-webui.nix` | `modules/60-apps/72-open-webui.nix` | ✅ Injected |
| .github | `workflows/auto-docs.yml` | `.github/workflows/auto-docs.yml` | ✅ Injected |

---

## 🚫 Excluded (Already Present)

The following source files were **not extracted** because equivalent logic already exists in the target from prior migrations (`mynixos-v5`, `mynixos-knowledge-base`):

- All `00-core/` files except `shell-premium.nix`, `symbiosis.nix`, `lib-helpers.nix`, `scripts/`
- All `10-gateway/` files except `adguardhome.nix`, `tailscale.nix`, `cloudflared-tunnel.nix`, `landing-zone-ui.nix`, `dns-map.nix`
- All `20-infrastructure/` files except `clamav.nix`, `secret-ingest.nix`
- All `30-automation/` files except `service-app-olivetin.nix`
- All `40-media/` files (already in target `50-media/`)
- All `50-knowledge/` files except `service-app-linkwarden.nix`
- All `60-apps/` files except `SERVICE_TEMPLATE.nix` (pattern already in target `_templates/`)
- All `80-monitoring/` files (already in target `40-monitoring/`)
- All `90-policy/` files except `security-assertions.nix`, `binary-only.nix`
- All `.legacy_folders/` content except `service-app-open-webui.nix`

---

## 🔐 Personal Data Stripped

All hardcoded values from the source have been removed:

- `q958` → parameterized via `my.core.identity.host`
- `m7c5.de` → parameterized via `my.core.identity.domain`
- `moritzbaumeister@gmail.com` → removed
- `192.168.2.73` → parameterized via `my.core.server.lanIP`
- `moritz` username → parameterized via `my.core.identity.user`
- Hardcoded IP references → replaced with config options
