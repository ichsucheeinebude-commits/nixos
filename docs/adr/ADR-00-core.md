---
domain: 00
id: "NIXH-00-COR-001"
title: "Core Foundation"
type: adr
status: draft
complexity: 3
reviewed: YYYY-MM-DD
tags:
  - core
  - foundation
  - nix-tuning
  - zram
  - boot
description: "Core system: configs, ports, nix-tuning, zram-swap, boot-safeguard, shell aliases"
provides:
  - my.core.enable
  - my.core.configs
  - my.core.ports
requires:
 []
links:
  adr: ADR-00-core.md
  guide: 00-core.md
  module: modules/00-core.nix
---

# ADR-00: Core Foundation

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
