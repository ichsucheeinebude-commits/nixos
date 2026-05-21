---
domain: 60
id: "NIXH-60-APP-004"
title: "Home Assistant Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [apps,home-assistant]
description: "Configure Home Assistant."
path: "docs/guides/GUIDE-63-home-assistant.md"
links:
  module: "modules/60-apps/63-home-assistant.nix"
---

# Guide: Home Assistant Guide

```nix
my.apps.homeAssistant.enable = true;
```


---

## KB Nuggets

=== HA Master-Interface-List
API-Endpunkte, Orchestrierung, MQTT-Discovery. Zigbee-Geräte über Coordinator.

---
## Home Assistant Blueprint (from KB)

---
title: "Service: Home Assistant (Aviation-Grade)"
category: "services"
tags: [automation, hass, mqtt, lovelace, dendritic]
id: "NIXH-30-AUT-003"
status: "audited"
last_reviewed: "2026-03-08"
sources: ["/tmp/mynixos_ro/30-automation/service-app-home-assistant.nix"]
---

# Service: Home Assistant (Smart Home Central)

## 1. User Layer (KISS)
Home Assistant ist das "Gehirn" deines Hauses. Es steuert deine Lichter, Heizungen und Sensoren. Dieses Modul sorgt dafür, dass die Zentrale sicher auf deinem Server läuft, alle deine Zigbee-Geräte (via MQTT) findet und dir ein schönes Dashboard (Lovelace) anzeigt. Alles ist so eingestellt, dass es auch von deinem Handy aus (Mobile App) sofort funktioniert.

## 2. Technical Layer (Aviation-Grade)

### Architektur & Integration
*   **Modus:** Deklarativ via NixOS. Das Dashboard wird über YAML-Konfigurationen gesteuert (`lovelace.mode = "yaml"`).
*   **MQTT-Anbindung:** Direkte Verdrahtung mit dem lokalen Mosquitto-Broker aus Layer 20.
*   **Netzwerk:** Konfiguriert für Reverse-Proxy Betrieb (`use_x_forwarded_for`) mit Vertrauen in lokale und Tailscale-IPs.

### UI & Dashboard (Lovelace)
Die Benutzeroberfläche ist im Code definiert:
*   **Wetter:** Integration von `weather.home`.
*   **System:** Anzeige des Sonnenstandes und System-Status.
*   **Verlinkung:** Direkter Button zur Zigbee-Verwaltungsoberfläche.

### SRE Hardening
*   **Isolation:** `ProtectSystem = "strict"` und `PrivateTmp = true`.
*   **Hardware:** Zugriff auf `/dev/dri` ist erlaubt (für Video-Processing oder KI-Beschleunigung).
*   **Priorität:** `OOMScoreAdjust = 300` (Hass wird eher beendet als Datenbanken, um Datenverlust zu vermeiden).

### Integration (Nix-Snippet)
```nix
services.home-assistant = {
  enable = true;
  extraComponents = [ "default_config" "mobile_app" "mqtt" "esphome" ];
  config.http = {
    use_x_forwarded_for = true;
    trusted_proxies = [ "127.0.0.1" "100.64.0.0/10" ];
  };
};
```

## 3. Reasoning Layer (History)

### [ADR-050] Declarative Lovelace vs. UI-Editing
*   **Status:** Entschieden (März 2026).
*   **Kontext:** Home Assistant erlaubt normalerweise das Ändern des Dashboards über die Webseite. Dies führt zu unkontrollierten Änderungen im State.
*   **Entscheidung:** Wir erzwingen den YAML-Modus für das Haupt-Dashboard.
*   **Vorteil:** Das Dashboard ist Teil des Git-Repositories und somit reproduzierbar und gegen versehentliche Änderungen geschützt.

### [ADR-051] Resource Priority
*   **Begründung:** Home Assistant ist
