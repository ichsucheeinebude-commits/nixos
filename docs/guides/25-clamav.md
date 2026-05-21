# ClamAV — Antivirus Protection

**Module:** `modules/20-security/25-clamav.nix`  
**Domain:** 20-security  
**Complexity:** ⭐

## Overview

ClamAV provides scheduled antivirus scanning with resource-aware scheduling.

## Enable

```nix
my.security.clamav.enable = true;
```

## Configuration

### Scan Directories

```nix
my.security.clamav.scanDirectories = [ "/home" "/var/lib" "/etc" ];
```

### Exclusions

```nix
my.security.clamav.excludePaths = [
  "^/mnt/media"
  "^/mnt/fast-pool/downloads"
];
```

### Schedule

Default: Saturday 03:00 (systemd calendar expression).

## Resource Limits

- CPUWeight = 20 (of 100)
- IOWeight = 20
- CPUSchedulingPolicy = idle
- IOSchedulingClass = idle
