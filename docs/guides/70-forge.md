---
domain: 70
id: "NIXH-70-FOR-001"
title: "Forge Self-Hosted Git"
type: guide
status: draft
complexity: 2
reviewed: YYYY-MM-DD
tags:
  - forgejo
  - git
  - ci-cd
description: "Forgejo, CI/CD, sovereign Git"
provides:
  - my.forge.enable
requires:
  - 00-core
  - 10-network
  - 20-security
links:
  adr: ADR-70-forge.md
  guide: 70-forge.md
  module: modules/70-forge.nix
---

# 70-forge: Forge Operations

> **One-sentence purpose statement.**
> [TODO]

---

## Prerequisites

Before touching anything in this domain:

- [ ] Domain `00-core` is deployed and healthy
- [ ] Domain `10-network` is deployed and healthy
- [ ] Secret `NAME_secret` exists in `/run/secrets/` (provisioned via SOPS)

---

## How It Works (Architecture in Plain Language)

[TODO — 3–5 sentences. No Nix. No code.]

1. **What starts it:** [TODO]
2. **What it talks to:** [TODO]
3. **What depends on it:** [TODO]

---

## Operational Procedures

### Enable / First Deploy

```bash
systemctl status NAME.service
ss -tlnp | grep NAME
curl -sf http://127.0.0.1:PORT/health && echo "OK"
```

### Disable / Remove

```bash
systemctl stop NAME.service
```

### Routine Maintenance

- Log rotation: automatic via systemd
- Backup verification: `restic snapshots --tag NAME`

---

## Verification Commands

```bash
systemctl is-active --quiet NAME && echo "PASS: active"
systemctl --failed | grep NAME || echo "PASS: no failures"
journalctl -u NAME --no-pager -n 100 | grep -c ERROR | grep -q "^0$" && echo "PASS: clean logs"
```

---

## Known Failure Modes

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Service in restart loop | SOPS secret not decrypted yet | Check `journalctl -u sops-nix` |
| Add domain-specific rows | — | — |

---

## Cross-Domain Interactions

- **Depends on:** `00-core` (users/groups), `10-network` (firewall)
- **Used by:** Higher-numbered domains
- **Shared state:** [TODO]

---

## Decision Reference

Architecture rationale lives in `docs/adr/ADR-70-forge.md`.
This guide deliberately contains no rationale — only operations.
