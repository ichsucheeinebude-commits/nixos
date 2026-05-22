---
domain: 70
id: "NIXH-70-DOM-001"
title: "Domain 70 — Forge Architecture"
type: adr
status: accepted
complexity: 3
reviewed: 2026-05-21
tags:
  - domain
  - 70
  - forge
  - architecture
description: "Architectural decisions for the 70-forge domain."
provides:
  - my.forge.*
requires:
  - my.core.*
  - my.network.*
links:
  adr: docs/adr/ADR-70-forge.md
  guide: docs/guides/70-forge.md
---

# ADR-70: Domain Forge Architecture

> Development infrastructure, LLM sandboxing, and web-based administration: self-hosted Git (Forgejo), Ansible UI (Semaphore), Cockpit, OpenTwin, Readeck, and jailed LLM agents via bubblewrap.

---

## Context

Domain 70 provides development and administration tools: Forgejo for sovereign Git hosting, Semaphore for Ansible automation with a web UI, and Cockpit for web-based system administration. These are infrastructure tools used by the system administrator, not end-user applications.

---

## Decisions

### 70-70: Forgejo
**Decision:** Self-hosted Git platform via Forgejo (community-driven Gitea fork). SQLite backend. No public registration. Native NixOS integration.
**Rationale:** Forgejo is fully open-source and community-governed (unlike Gitea's corporate direction). SQLite is sufficient for homelab scale. No public registration prevents unauthorized access.
**Alternatives considered:** Gitea (rejected — corporate direction concerns), GitLab (rejected — too resource-heavy), GitHub (rejected — not self-hosted).

### 70-71: Semaphore
**Decision:** Self-hosted Ansible Tower alternative. PostgreSQL backend. Placeholder module — implementation TBD.
**Rationale:** Web UI for Ansible playbooks enables team collaboration and audit trails. PostgreSQL integrates with shared instance.
**Alternatives considered:** AWX (rejected — too resource-heavy), manual ansible-playbook (rejected — no audit trail, no UI).

### 70-72: Cockpit
**Decision:** Web-based system administration via Cockpit. Native systemd integration.
**Rationale:** Cockpit provides real-time system monitoring and basic admin tasks via browser. Useful for quick checks without SSH.
**Alternatives considered:** Webmin (rejected — outdated), custom admin UI (rejected — reinventing the wheel).

### 70-73: OpenTwin
**Decision:** Placeholder for OpenTwin integration. TBD.
**Rationale:** Future digital twin capability for infrastructure simulation.
**Alternatives considered:** None yet.

### 70-74: Readeck
**Decision:** Placeholder for Readeck integration. TBD.
**Rationale:** Read-it-later service integration with development workflow.
**Alternatives considered:** None yet.

### 70-75: Jailed Agents (jailed-agents pattern)
**Decision:** Secure bubblewrap sandbox for LLM coding agents (jailed-agents, 59⭐). Zero-trust isolation: agents have no access to home directory, SSH keys, or sensitive files by default. Pre-configured builders for OpenCode, Claude Code, and Crush. Custom agent builder via `makeJailedAgent`. Declarative directory access (readwrite/readonly), package whitelist, network confinement. Uses `bubblewrap` (Flatpak's sandboxing engine) + `jail.nix` patterns. Unprivileged user namespaces enabled.
**Rationale:** LLM agents need system tool access (git, curl, node, python) but must not read SSH keys, /etc/shadow, or other sensitive data. bubblewrap provides lightweight, kernel-native isolation without Docker overhead. Declarative config ensures reproducible sandbox policies.
**Alternatives considered:** Docker (rejected — heavy, requires duplicating Nix environment), nsjail (rejected — less Nix-native), no sandbox (rejected — security risk).

---

## Consequences

### Positive
- Sovereign Git hosting — no GitHub dependency
- Ansible web UI enables playbook management and audit
- Cockpit provides visual system overview
- All tools self-hosted

### Negative
- Forgejo + Semaphore + Cockpit consume resources
- Semaphore is still TBD — incomplete functionality
- Cockpit adds another web UI surface to secure

---

## Module Inventory

| Module | Purpose |
|--------|---------|
| 70-forgejo.nix | Self-hosted Git platform (Gitea fork) |
| 71-semaphore.nix | Ansible web UI (TBD) |
| 72-cockpit.nix | Web-based system administration |
| 73-opentwin.nix | Digital twin for infrastructure simulation (TBD) |
| 74-readeck.nix | Read-it-later service integration (TBD) |
| 75-jailed-agents.nix | LLM agent sandbox: bubblewrap, zero-trust, declarative access control |

---

## Cross-Domain Dependencies

- Depends on: Domain 00 (core), Domain 10 (network, Caddy), Domain 20 (security)
- Used by: Domain 90 (policy — security assertions may reference forge services)
