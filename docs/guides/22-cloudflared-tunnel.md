# Cloudflare Tunnel

**Module:** `modules/10-network/22-cloudflared-tunnel.nix`  
**Domain:** 10-network  
**Complexity:** ⭐⭐

## Overview

Cloudflare Tunnel provides zero-port-forwarding ingress by creating an outbound connection to Cloudflare's edge.

## Enable

```nix
my.network.cloudflared.enable = true;
my.network.cloudflared.tunnelId = "your-tunnel-id";
my.network.cloudflared.credentialsFile = "/run/secrets/cloudflared_credentials.json";
```

## Credentials

The tunnel credentials JSON file must be stored via SOPS:

```yaml
# secrets.yaml
cloudflared_credentials: |
  {"TunnelID":"...","TunnelSecret":"..."}
```

## Wildcard Ingress

By default, `*.nix.<domain>` is routed to the local Caddy proxy at `https://127.0.0.1:443`.

## Sandboxing

- ProtectSystem = strict
- NoNewPrivileges = true
- CapabilityBoundingSet: CAP_NET_BIND_SERVICE, CAP_NET_RAW
- OOMScoreAdjust = -500
