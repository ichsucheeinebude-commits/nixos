---
domain: 70
id: "NIXH-70-FOR-001"
title: "Forge Self-Hosted Git"
type: adr
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

# ADR-70: Forge — Self-Hosted Git

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
