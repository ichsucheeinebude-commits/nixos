---
domain: 80
id: "NIXH-80-GAM-001"
title: "Gaming and Game Servers"
type: adr
status: draft
complexity: 2
reviewed: YYYY-MM-DD
tags:
  - gaming
  - amp
  - fhs
  - game-servers
description: "FHS game servers, AMP"
provides:
  - my.gaming.enable
requires:
  - 00-core
  - 10-network
  - 30-storage
links:
  adr: ADR-80-gaming.md
  guide: 80-gaming.md
  module: modules/80-gaming.nix
---

# ADR-80: Gaming PLACEHOLDER_TITLE Game Servers

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
