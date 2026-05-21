---
title: "ADR-XX: Short Decision Title"
domain: XX
status: proposed # proposed | accepted | deprecated | superseded
severity: high   # critical | high | medium | low
date: YYYY-MM-DD
deciders: [moritz]
review_after: YYYY-MM-DD   # 6–12 Monate → zwingt zur Re-Evaluation
links:
  guide: XX-name.md
  modules:
    - modules/XX-name/relevant-module.nix
  related: []              # Andere ADRs die betroffen sind
  issues: []               # GitHub Issue IDs
  source: []               # Externe Quellen/Doku die die Entscheidung stützen
supersedes: []             # ADR-Dateien die diese hier ersetzt
---

# ADR-XX: Short Decision Title

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
- Noch ein konkreter Vorteil

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

**Warum abgelehnt:** Ein Satz. Wenn "nicht ausprobiert" — so sagen.

---

### Option C: [Name] ← ABGELEHNT
_(Nur wenn tatsächlich evaluiert — nicht um die ADR aufzublähen)_

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
- Spezifisches Risiko → Mitigation: [wie wir es addressieren]

---

## Rollback

Was passiert wenn die Entscheidung falsch war?
1. Schritt 1: [was zurückbauen]
2. Schritt 2: [was neu aufsetzen]
3. Datenverlust-Risiko: [Ja/Nein, was passiert mit bestehenden Daten]

---

## Validation

Konkrete Checks die vor/nach dem Deploy durchgehen:

- [ ] Check 1: [konkreter Befehl / Messwert]
- [ ] Check 2: [konkreter Befehl / Messwert]
- [ ] Check 3: [konkreter Befehl / Messwert]

**Review-Trigger:** ADR neu bewerten wenn [konkreter Zustand] eintritt.
**Scheduled review:** Siehe `review_after` im Frontmatter.

---

## Offene Fragen

_(Fragen die zum Zeitpunkt der Entscheidung noch nicht geklärt sind.
Keine Frage hier stehen lassen ohne Verantwortlich und Deadline.)_

- [ ] Frage? → Verantwortlich: @name, bis: YYYY-MM-DD

---

<!-- CONSTRAINT REMINDER (vor Commit löschen)
  Diese ADR beantwortet WARUM. Sie darf NICHT enthalten:
  - Nix-Code (→ gehört ins Modul)
  - Schritt-für-Schritt-Anleitungen (→ gehört in den Guide)
  - Vage Begründungen wie "ist einfacher" ohne "einfacher für wen"
  Wenn du HOW schreibst → stopp und verschiebe es in den Guide.
-->
