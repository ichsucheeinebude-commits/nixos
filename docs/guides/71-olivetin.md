# OliveTin — Web Control Panel

**Module:** `modules/60-apps/71-olivetin.nix`  
**Domain:** 60-apps  
**Complexity:** ⭐⭐

## Overview

Web-based control panel with Wake-on-Access (Socket Activation) and secure command pinning.

## Enable

```nix
my.apps.olivetin.enable = true;
```

## Pre-configured Actions

| Action | Description |
|--------|-------------|
| SOPS: Neues Secret | Create a new SOPS secret via web UI |
| mTLS: Client Zertifikat | Generate mTLS client certificate |
| System Update | Run nixos-rebuild switch |

## Socket Activation

The service only starts when a connection arrives on the configured port. This saves resources when the control panel is not in use.

## Sudo Rules

The olivetin user gets sudo access only for:
- `nixos-rebuild`
- `mtls-generator.sh`

No blanket `ALL` access.
