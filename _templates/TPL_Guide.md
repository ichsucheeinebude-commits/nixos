---
domain: XX
id: "NIXH-XX-XXX-001"
title: "REPLACE_TITLE"
type: guide
status: draft
complexity: 1
reviewed: YYYY-MM-DD
tags:
  - REPLACE_TAG
description: "REPLACE_DESCRIPTION"
provides: []
requires: []
links:
  adr: ADR-XX-name.md
  guide: XX-name.md
  module: modules/XX-name.nix
---

# XX-name: REPLACE_TITLE

> **One-sentence purpose statement.**
> What this domain does at runtime, for whom, and why it exists.

---

## Prerequisites

Before touching anything in this domain:

- [ ] Domain `00-core` is deployed and healthy
- [ ] Domain `10-network` is deployed and healthy
- [ ] Required secrets exist in `/run/secrets/`

---

## How It Works (Architecture in Plain Language)

Describe the runtime data flow in 3–5 sentences. No Nix. No code.

1. **What starts it:** Which systemd target pulls this service in.
2. **What it talks to:** Other local services, network endpoints, storage paths.
3. **What depends on it:** Which higher-numbered domains need this running first.

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
| Service in restart loop | SOPS secret not decrypted | Check `journalctl -u sops-nix` |
| Port already in use | Leftover process | `fuser -k PORT/tcp` then redeploy |

---

## Cross-Domain Interactions

- **Depends on:** `00-core` (users/groups), `10-network` (firewall)
- **Used by:** Higher-numbered domains
- **Shared state:** [TODO]

---

## Decision Reference

Architecture rationale lives in `docs/adr/ADR-XX-name.md`.
This guide deliberately contains no rationale — only operations.
If you find yourself asking *why*, read the ADR.
