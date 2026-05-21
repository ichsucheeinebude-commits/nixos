# AdGuard Home — DNS Filtering

**Module:** `modules/10-network/20-adguardhome.nix`  
**Domain:** 10-network  
**Complexity:** ⭐⭐

## Overview

AdGuard Home provides network-wide DNS filtering with blocklists, DNSSEC, and optimized caching.

## Enable

```nix
my.network.adguardhome.enable = true;
```

## Configuration

### Upstream DNS

```nix
my.network.adguardhome.upstreamDns = [
  "https://1.1.1.1/dns-query"
  "https://8.8.8.8/dns-query"
];
```

### Blocklists

Default blocklists include AdGuard Base, AdGuard Tracking, StevenBlack, and OISD Small.

### DNS Rewrites

```nix
my.network.adguardhome.dnsRewrites = [
  { domain = "myhost.local"; answer = "192.168.1.100"; }
];
```

## Sandboxing

- CapabilityBoundingSet: CAP_NET_BIND_SERVICE, CAP_NET_RAW
- ProtectSystem = strict
- NoNewPrivileges = true
- SystemCallFilter = ["@system-service" "~@privileged" "~@resources"]
