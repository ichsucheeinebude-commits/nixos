---
domain: 10
id: "NIXH-10-NET-004"
title: "SSH Rescue Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [network,ssh,rescue]
description: "Enable rescue SSH."
path: "docs/guides/GUIDE-13-ssh-rescue.md"
links:
  module: "modules/10-network/13-ssh-rescue.nix"
---

# Guide: SSH Rescue Guide

```nix
my.network.sshRescue.enable = true;
```


---

## KB Nuggets

### Rescue Window Implementierung
Timer-basierter SSH-Port der nur nach Boot für 5 Minuten lauscht. Fallback bei Lockout.

---
## SSH Rescue Window (from KB)

# Service: SSH Rescue Window (Emergency Access)

## 1. User Layer (KISS)
Dieses Dokument beschreibt dein Sicherheitsnetz gegen das "Aussperren". Nach jedem Neustart des Servers öffnet sich ein Zeitfenster von genau 5 Minuten, in dem du dich auch ohne SSH-Key (nur mit deinem Passwort) einloggen kannst. Das ist extrem hilfreich, wenn du deinen SSH-Key verloren hast oder von einem fremden Gerät aus schnell auf den Server musst. Nach den 5 Minuten schließt sich die Tür automatisch wieder und nur noch deine sicheren Keys werden akzeptiert.

## 2. Technical Layer (Aviation-Grade)

### Funktionsweise
Das Modul implementiert einen flüchtigen Konfigurations-Override für `sshd`:
1.  **Trigger:** Start der systemd-Unit `ssh-recovery-window` nach erfolgreichem Boot.
2.  **Aktion:** Backup der `sshd_config` -> Aktivierung von `PasswordAuthentication yes` via `sed`.
3.  **Timer:** Wartezeit von 300 Sekunden (5 Minuten).
4.  **Rollback:** Wiederherstellung der Originalkonfiguration -> `systemctl reload sshd`.

### Operative Werkzeuge
*   **`ssh-recovery-status`:** Zeigt an, ob das Fenster aktuell offen (gelb) oder geschlossen (grün) ist.
*   **Aliase:**
    *   `ssh-recovery-enable`: Erlaubt das manuelle Öffnen des Fensters im laufenden Betrieb.

### Integration (Nix-Snippet)
```nix
systemd.services.ssh-recovery-window = {
  description = "SSH Password Recovery Window";
  wantedBy = ["multi-user.target"];
  after = ["sshd.service"];
  serviceConfig.ExecStart = "..."; # Bash-Logik siehe oben
};
```

## 3. Reasoning Layer (History)

### [ADR-023] Temporary Password Auth vs. Recovery Shell
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Physischer Zugriff auf den Server (Fujitsu Q958) ist oft schwierig (steht im Keller/Schrank). Eine Recovery-Shell am Monitor hilft im Headless-Betrieb nicht weiter.
*   **Entscheidung:** Einführung eines zeitgesteuerten Netzwerk-Rettungsfensters.
*   **Sicherheits-Abwägung:** Das Risiko eines Brute-Force Angriffs in einem 5-Minuten-Fenster u
