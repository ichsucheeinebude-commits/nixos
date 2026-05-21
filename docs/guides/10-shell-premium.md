# Shell Premium — Advanced Shell Environment

**Module:** `modules/00-core/10-shell-premium.nix`  
**Domain:** 00-core  
**Complexity:** ⭐⭐

## Overview

Shell Premium transforms the standard login experience into an information-rich, tool-enhanced workspace.

## Enable

```nix
my.core.shell.premium.enable = true;
```

## Features

### Fastfetch MOTD

Custom system information display showing:
- OS, Kernel, Uptime
- CPU, GPU, Memory
- Disk usage
- LAN IP
- Dashboard URL

### Service Status Checker

Runs `check-services` to verify:
- SSH daemon
- Caddy proxy
- Tailscale VPN
- Fail2ban

### Alias Suite

| Alias | Command |
|-------|---------|
| `nsw` | `sudo nixos-rebuild switch` |
| `ntest` | `sudo nixos-rebuild test` |
| `ndry` | `sudo nixos-rebuild dry-run` |
| `nup` | `nix flake update` |
| `ngit` | `cd /etc/nixos && git status -sb` |
| `sysinfo` | `fastfetch --config <homelab-config>` |
| `services` | `check-services` |

### Tool Upgrades

| Standard | Replacement |
|----------|-------------|
| `ls` | `eza --icons` |
| `cat` | `bat --paging=never` |
| `df` | `duf` |
| `du` | `dust` |
| `top` | `htop` |
