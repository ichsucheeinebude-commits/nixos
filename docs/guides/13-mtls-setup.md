# mTLS Certificate Generation

**Script:** `modules/00-core/scripts/mtls-generator.sh`  
**Domain:** 00-core  
**Complexity:** ⭐⭐

## Overview

Generates a self-signed mTLS Certificate Authority (CA) and issues client certificates signed by that CA. Certificates are exported as PKCS#12 (.p12) for easy import into browsers and mobile devices.

## Prerequisites

- OpenSSL
- Root access (for creating CA and client certificates)
- Caddy service running (for serving certificates)

## Usage

### Generate CA (First Run)

The CA is automatically generated on first use:

```bash
sudo bash /etc/nixos/modules/00-core/scripts/mtls-generator.sh
```

This creates:
- `/etc/nixos/secrets/mtls/ca.key` — CA private key (mode 0600)
- `/etc/nixos/secrets/mtls/ca.crt` — CA certificate (10-year validity)

### Generate Client Certificate

```bash
sudo bash /etc/nixos/modules/00-core/scripts/mtls-generator.sh <client_name>
```

Example:
```bash
sudo bash /etc/nixos/modules/00-core/scripts/mtls-generator.sh macbook-pro
```

Output:
- `/var/www/landing-zone/certs/<client_name>.p12` — PKCS#12 bundle

### Install Client Certificate

1. Download the `.p12` file from the landing zone certs directory
2. Import into browser (Chrome → Settings → Privacy → Manage Certificates)
3. Password is **empty** (the certificate itself is the protection)

## Certificate Flow

```
┌─────────────────────────┐
│  mTLS-Generator Script  │
│                         │
│  1. Create CA (if new)  │  → ca.key + ca.crt
│  2. Generate Client Key │  → <name>.key
│  3. Create CSR          │  → <name>.csr
│  4. Sign with CA        │  → <name>.crt
│  5. Export PKCS#12      │  → <name>.p12
│  6. Cleanup CSR         │  (deleted)
└─────────────────────────┘
```

## SRE Notes

- CA private key is stored with mode 0600 (owner-only access)
- Client certificates have 1-year validity
- PKCS#12 export has empty password (homelab-appropriate; the .p12 file itself is the secret)
- Certificate ownership is set to `caddy:caddy` for serving via landing zone
