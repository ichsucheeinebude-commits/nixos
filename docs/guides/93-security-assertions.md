---
domain: 90
id: "NIXH-90-POL-003"
title: "Security Assertions Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - policy
  - assertions
  - security
  - enforcement
description: "How security assertions enforce critical settings and can be bypassed via bastelmodus."
provides:
  - my.policy.securityAssertions
requires:
  - my.network.firewall
  - my.network.ssh
  - my.core.bastelmodus
links:
  adr: ADR-93-security-assertions.md
  guide: 93-security-assertions.md
  module: modules/90-policy/93-security-assertions.nix
---

# 93-security-assertions: Security Assertions

> Fail-safe enforcement of critical security settings during NixOS evaluation.

---

## Prerequisites

- [ ] Domain `00-core` is deployed and healthy
- [ ] Domain `10-network` with firewall configured
- [ ] Domain `20-security` with SSH hardening configured

---

## How It Works

Security assertions use NixOS's native `config.assertions` mechanism. During evaluation, each assertion is checked. If any fail, `nixos-rebuild` aborts before deployment.

1. **`must` helper** — Shorthand syntax for assertion + message.
2. **Bastelmodus bypass** — `my.core.bastelmodus = true` skips all assertions.
3. **Critical checks** — Firewall, NFTables, SSH root login.

---

## Operational Procedures

### Enable

```nix
my.policy.securityAssertions.enable = true;
```

### Bypass (Development)

```nix
my.core.bastelmodus = true;
```

---

## Verification

```bash
nixos-rebuild dry-run 2>&1 | grep -i assertion
```

---

## Known Failure Modes

| Symptom | Cause | Fix |
|---------|-------|-----|
| `assertion failed` | Security setting not met | Fix setting or enable bastelmodus |

---

## Cross-Domain Interactions

- **Depends on:** `10-network/11-firewall.nix`, `10-network/12-ssh.nix`
- **Bypass:** `my.core.bastelmodus` from 00-core
