---
domain: 60
id: "NIXH-60-APP-001"
title: "Applications"
type: adr
status: draft
complexity: 2
reviewed: YYYY-MM-DD
tags:
  - apps
  - paperless
  - n8n
  - vaultwarden
description: "Paperless, n8n, Vaultwarden"
provides:
  - my.apps.enable
requires:
  - 00-core
  - 10-network
  - 20-security
links:
  adr: ADR-60-apps.md
  guide: 60-apps.md
  module: modules/60-apps.nix
---

# ADR-60: Applications

> **Entscheidung in einem Satz.**
> [TODO]

---

## Context

**Was ist das Problem?**
[TODO]
- System-Constraints (Hardware, NixOS-Version, Impermanence)
- Operationale Constraints (Single-Admin, Headless, Remote-Only)
- Abhängigkeiten

**Warum ist das relevant?**
[TODO]

---

## Considered Alternatives

### Option A: [Name] ← GEWÄHLT

**Was es ist:** [TODO]

**Pro:**
- [TODO]

**Contra:**
- [TODO]

**Warum gewählt:** [TODO]

---

### Option B: [Name] ← ABGELEHNT

**Was es ist:** [TODO]

**Pro:**
- [TODO]

**Contra:**
- [TODO]

**Warum abgelehnt:** [TODO]

---

## Decision

**Wir wählen Option A.**

Scope: [TODO]

---

## Consequences

**Positiv:**
- [TODO]

**Negativ:**
- [TODO]

**Risiken:**
- [TODO]

---

## Rollback

1. [TODO]
2. [TODO]
3. Datenverlust-Risiko: [TODO]

---

## Validation

- [ ] Check 1: [TODO]
- [ ] Check 2: [TODO]

**Review-Trigger:** [TODO]

---

## Offene Fragen

- [ ] Frage? → Verantwortlich: @name, bis: YYYY-MM-DD

---

<!-- CONSTRAINT REMINDER (vor Commit löschen)
  Diese ADR beantwortet WARUM. Sie darf NICHT enthalten:
  - Nix-Code (→ gehört ins Modul)
  - Schritt-für-Schritt-Anleitungen (→ gehört in den Guide)
  - Vage Begründungen wie "ist einfacher" ohne "einfacher für wen"
-->
