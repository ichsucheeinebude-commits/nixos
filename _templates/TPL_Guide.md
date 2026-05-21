---
title: "XX-name: Short Operational Title"
domain: XX
folder: XX-name
status: draft # draft | active | deprecated
complexity: 2
last_reviewed: YYYY-MM-DD
links:
  adr: ADR-XX-name.md
  modules:
    - path: modules/XX-name/primary-module.nix
      anchor: anchor-name-in-module

> **One-sentence purpose statement.**
> What this domain does at runtime, for whom, and why it exists.

---

## Prerequisites

Before touching anything in this domain:

- [ ] Domain `00-core` is deployed and healthy
- [ ] Domain `10-network` is deployed and healthy
- [ ] Required secrets exist in `/run/secrets/`

---

## Data Flow

Describe the runtime data flow. No Nix. No code.

1. **What starts it:** Which systemd target pulls this service in.
2. **What it talks to:** Other local services, network endpoints, storage paths.
3. **What depends on it:** Which higher-numbered domains need this running first.

---

## Operations

### Start / Check Status

```bash
systemctl status NAME.service
ss -tlnp | grep NAME
curl -sf http://127.0.0.1:PORT/health && echo "OK"
```

### Stop

```bash
systemctl stop NAME.service
```

### Weekly / Monthly Tasks

- Log rotation: automatic via systemd
- Backup verification: `restic snapshots --tag NAME`
- Secret rotation: See `docs/guides/20-security.md#secret-rotation`

---

## Health Checks

All must pass before a deploy is considered healthy:

```bash
systemctl is-active --quiet NAME && echo "PASS: active"
systemctl --failed | grep NAME || echo "PASS: no failures"
curl -sf http://127.0.0.1:PORT/health | grep -q '"status":"ok"' && echo "PASS: healthy"
```

---

## Troubleshooting

| Symptom | Likely Cause | Fix |
|---------|-------------|-----|
| Service in restart loop | SOPS secret not decrypted | Check `journalctl -u sops-nix` |
| Port already in use | Leftover process | `fuser -k PORT/tcp` then redeploy |
| Permission denied | Wrong uid in users.registry | Verify user/group config |

---

## Dependencies

- **Depends on:** `00-core` (users/groups), `10-network` (firewall)
- **Used by:** Higher-numbered domains
- **Shared state:** Describe shared files, sockets, databases

---

Architecture rationale lives in `docs/adr/ADR-XX-name.md`.
This guide deliberately contains no rationale — only operations.
If you find yourself asking *why*, read the ADR.
