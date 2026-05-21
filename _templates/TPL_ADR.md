---
domain: XX
id: "NIXH-XX-XXX-001"
title: "REPLACE_TITLE"
type: adr
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

# ADR-XX: REPLACE_TITLE

> **Entscheidung in einem Satz.**
> Wir nutzen X statt Y weil Z.

---

## Context

**Was ist das Problem?**
Konkrete Beschreibung. Keine vagen Aussagen.
- System-Constraints (Hardware, NixOS-Version, Impermanence)
- Operationale Constraints (Single-Admin, Headless, Remote-Only)
- Abhängigkeiten (was wurde schon entschieden das hier einschränkt)

**Warum ist das relevant?**
Was passiert wenn wir keine Entscheidung treffen?

---

## Considered Alternatives

### Option A: [Name] ← GEWÄHLT

**Was es ist:** 1–2 Sätze.

**Pro:**
- Konkreter Vorteil

**Contra:**
- Ehrlicher Nachteil (jede Option hat einen)

**Warum gewählt:** Ein Satz der die dominante Kraft aus Context adressiert.

---

### Option B: [Name] ← ABGELEHNT

**Was es ist:** 1–2 Sätze.

**Pro:**
- Konkreter Vorteil

**Contra:**
- Der spezifische Ablehnungsgrund

**Warum abgelehnt:** Ein Satz.

---

## Decision

**Wir wählen Option A.**

Scope: Diese Entscheidung gilt für [was] und gilt NICHT für [was].

---

## Consequences

**Positiv:**
- Was wird einfacher/besser
- Welches Risiko wird eliminiert

**Negativ:**
- Was wird schwerer (ehrlich sein)
- Welche Flexibilität geht verloren

**Risiken:**
- Spezifisches Risiko → Mitigation: [wie]

---

## Rollback

1. Schritt 1: [was zurückbauen]
2. Schritt 2: [was neu aufsetzen]
3. Datenverlust-Risiko: [Ja/Nein]

---

## Validation

- [ ] Check 1: [konkreter Befehl / Messwert]
- [ ] Check 2: [konkreter Befehl / Messwert]

**Review-Trigger:** ADR neu bewerten wenn [konkreter Zustand] eintritt.
**Scheduled review:** Siehe `reviewed` im Frontmatter.

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
