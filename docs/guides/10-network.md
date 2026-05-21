---
domain: 10
id: "NIXH-10-DOM-001"
title: "Domain 10 — Network Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 10
  - network
  - operations
description: "Operational guide for the 10-network domain."
links:
  adr: ADR-10-network.md
  guide: 10-network.md
---

# 10-network: Domain Network Guide

> Operational procedures for all networking, DNS, reverse proxy, identity, and remote access services.

---

## Prerequisites

- Domain 00 (core) deployed
- Hardware with network interface configured
- Cloudflare account with DNS zone
- SOPS secrets prepared (Cloudflare token, Tailscale auth key, etc.)

---

## Module Operations (ODR-sorted)

### 10-10: Network Configuration
**Enable:** Base networking auto-enabled. Configure `networking.hostName` and DNS servers in host config.
**Verify:** `resolvectl status` shows systemd-resolved. `resolvectl query google.com` tests resolution.
**Troubleshooting:** DNS not resolving — check `systemctl status systemd-resolved`. Verify DNS servers in config.

### 10-11: NFTables Firewall
**Enable:** `my.network.firewall.enable = true;` Configure allowed ports via `my.network.firewall.allowedTCPPorts`.
**Verify:** `nft list ruleset` shows active rules. `nft list chains` shows chain policies.
**Troubleshooting:** Port not accessible — verify rule exists and service is bound to correct interface.

### 10-12: SSH Server
**Enable:** SSH enabled by default. Set `services.openssh.port`. Keys in `users.<name>.openssh.authorizedKeys`.
**Verify:** `sshd -T` shows effective config. `ssh -p <port> user@host` tests connection.
**Troubleshooting:** Connection refused — check firewall rules. Key rejected — verify authorized_keys.

### 10-13: SSH Rescue
**Enable:** Enabled automatically. 5-minute window opens after each boot.
**Verify:** `systemctl status sshd-rescue` shows timer. Check rescue port in firewall rules.
**Troubleshooting:** Rescue not available — window may have expired. Reboot to reopen.

### 10-14: Blocky DNS
**Enable:** `my.network.blocky.enable = true;` Configure block lists in module options.
**Verify:** `dig @127.0.0.1 example.com` tests local resolution. Blocky web UI at configured port.
**Troubleshooting:** Ads not blocked — check block list update status. DNS slow — increase cache size.

### 10-15: Caddy Reverse Proxy
**Enable:** `my.network.caddy.enable = true;` DNS-01 requires Cloudflare API token in SOPS secrets.
**Verify:** `curl -k https://<service>.<domain>` returns 200. `caddy list-modules` shows loaded modules.
**Troubleshooting:** TLS failures — check DNS-01 challenge logs. `journalctl -u caddy -f`. 502 errors — backend service not running.

### 10-16: DNS Automation
**Enable:** Timer auto-enabled. Check Cloudflare DNS conflict detection.
**Verify:** `systemctl list-timers | grep dns` shows schedule. Check logs for conflict reports.
**Troubleshooting:** Conflicts detected — resolve duplicate DNS entries in Cloudflare dashboard.

### 10-17: Pocket-ID
**Enable:** `my.network.pocketId.enable = true;` First user setup via web UI.
**Verify:** `curl http://localhost:<port>/api/health` returns 200. OIDC discovery: `curl http://localhost:<port>/.well-known/openid-configuration`.
**Troubleshooting:** OIDC failing — check client configuration in Cloudflare Access. Passkey not working — check browser WebAuthn support.

### 10-18: DDNS Updater
**Enable:** `my.network.ddns.enable = true;` Cloudflare API token with DNS:Edit permission.
**Verify:** Check DNS record update timestamps in Cloudflare dashboard. `journalctl -u ddns-updater`.
**Troubleshooting:** IP not updating — check API token permissions. Verify current IP matches DNS record.

### 10-19: Zigbee Stack
**Enable:** `my.network.zigbee.enable = true;` USB Zigbee stick must be connected.
**Verify:** `systemctl status mosquitto`. `systemctl status zigbee2mqtt`. Check Zigbee2MQTT web UI.
**Troubleshooting:** Stick not detected — check `/dev/serial/by-id/`. MQTT not connecting — verify broker address.

### 10-20: AdGuard Home
**Enable:** `my.network.adguardHome.enable = true;` Configure blocklists and upstream DNS.
**Verify:** AdGuard web UI accessible. `dig @<adguard-ip> example.com` tests resolution.
**Troubleshooting:** Port conflict with Blocky — only one DNS resolver should be primary.

### 10-21: Tailscale
**Enable:** `my.network.tailscale.enable = true;` Auth key in SOPS secrets.
**Verify:** `tailscale status` shows connection. `tailscale ip` shows assigned IP.
**Troubleshooting:** Not connected — check auth key validity. `tailscale login` for manual auth.

### 10-22: Cloudflare Tunnel
**Enable:** `my.network.cloudflared.enable = true;` Tunnel credentials and ID in SOPS secrets.
**Verify:** `cloudflared tunnel info <tunnel-id>` shows status. Check Cloudflare Zero Trust dashboard.
**Troubleshooting:** Tunnel not connecting — verify credentials file exists. Check `journalctl -u cloudflared`.

### 10-23: Landing Zone UI
**Enable:** Auto-enabled as Caddy default vhost when Caddy is active.
**Verify:** `curl http://<host-ip>/` returns landing page HTML.
**Troubleshooting:** Page not showing — check Caddy default vhost configuration.

### 10-24: DNS Map
**Enable:** Edit `my.network.dnsMap` attrset in config. Add new service → subdomain mappings.
**Verify:** `getent hosts <service>.<domain>` resolves. Caddy auto-generates vhosts.
**Troubleshooting:** New service not resolving — rebuild required for DNS Map changes to propagate.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core), Domain 20 (security, firewall rules)
- Used by: All service domains (reverse proxy, DNS, SSO)
