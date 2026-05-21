# Secret Ingest — Landing Zone Pipeline

**Module:** `modules/20-security/26-secret-ingest.nix`  
**Domain:** 20-security  
**Complexity:** ⭐⭐

## Overview

Automated secret processing via a watched landing zone directory.

## Enable

```nix
my.security.secretIngest.enable = true;
```

## Usage

1. Drop a SOPS-encrypted file into `/etc/nixos/secret-landing-zone/`
2. The systemd.path watcher detects the new file
3. The ingest service decrypts and moves it to `.processed/`

## Architecture

```
/etc/nixos/secret-landing-zone/
├── secret.yaml.enc     ← drop here
└── .processed/
    └── secret.yaml.enc ← moved here after processing
```

## SOPS Requirement

The Python processor uses `sops -d` to decrypt files. The SOPS age key must be available on the system.
