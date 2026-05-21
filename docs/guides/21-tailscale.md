# Tailscale — Zero-Touch VPN

**Module:** `modules/10-network/21-tailscale.nix`  
**Domain:** 10-network  
**Complexity:** ⭐⭐

## Overview

Tailscale provides automatic WireGuard VPN with SOPS-intenticated auth keys.

## Enable

```nix
my.network.tailscale.enable = true;
```

## Auth Key

The auth key must be stored in SOPS:

```yaml
# secrets.yaml
tailscale_token: "tskey-auth-xxxxx"
```

## Auto-Connect

After reboot, a one-shot service checks the Tailscale status and authenticates automatically if needed. No manual `tailscale up` required.

## Features

- SSH support (`--ssh` flag)
- DNS acceptance (`--accept-dns=true`)
- Route acceptance (`--accept-routes=true`)
- Caddy certificate permission (PermitCertUid)
- High daemon priority (OOMScoreAdjust = -1000)
