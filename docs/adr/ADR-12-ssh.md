---
domain: 10
id: "NIXH-10-NET-003"
title: "SSH Server"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh]
description: "OpenSSH configuration."
path: "docs/adr/ADR-12-ssh.md"
links:
  module: "modules/10-network/12-ssh.nix"
---

# ADR: SSH Server

## Decision
Key-only auth, configurable port.


---

## KB Nuggets

### SSH ProxyJump Standard
Admin-Zugang via ProxyJump durch Cloudflare Tunnel. Kein direkter SSH-Port nach außen.
### Post-Quantum Crypto
`KEM algorithms: sntrup761x25519-sha512` für zukunftssichere SSH-Verschlüsselung.
