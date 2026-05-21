---
domain: 60
id: "NIXH-60-DOM-001"
title: "Domain 60 — Apps Guide"
type: guide
status: draft
complexity: 2
reviewed: 2026-05-21
tags:
  - domain
  - 60
  - apps
  - operations
description: "Operational guide for the 60-apps domain."
links:
  adr: ADR-60-apps.md
  guide: 60-apps.md
---

# 60-apps: Domain Apps Guide

> Operational procedures for knowledge management, automation, identity, communication, and AI services.

---

## Prerequisites

- Domain 00 (core, PostgreSQL) deployed
- Domain 10 (network, Caddy, Pocket-ID SSO) active
- Domain 20 (security, secrets) configured
- Domain 10-19 (Zigbee/MQTT) for Home Assistant

---

## Module Operations (ODR-sorted)

### 60-60: Paperless-ngx
**Enable:** `my.apps.paperless.enable = true;` Configure OCR language, consumption directory, PostgreSQL connection.
**Verify:** Paperless web UI accessible. Test document upload with OCR processing.
**Troubleshooting:** OCR failing — check tesseract language packs. PostgreSQL connection refused — verify database exists.

### 60-61: n8n Automation
**Enable:** `my.apps.n8n.enable = true;` Encryption key from SOPS. OIDC via Pocket-ID.
**Verify:** n8n web UI accessible. Test workflow execution. `journalctl -u n8n` shows startup.
**Troubleshooting:** Encryption key missing — check SOPS secrets. OIDC failing — verify Pocket-ID client config.

### 60-62: Vaultwarden
**Enable:** `my.apps.vaultwarden.enable = true;` Set `SIGNUPS_ALLOWED = false` after initial setup.
**Verify:** Vaultwarden web UI accessible. Test login with Bitwarden client.
**Troubleshooting:** Signups not working — check `SIGNUPS_ALLOWED`. Database corruption — restore from backup.

### 60-63: Home Assistant
**Enable:** `my.apps.homeAssistant.enable = true;` Minimal config — use HA UI for setup.
**Verify:** HA web UI accessible. Zigbee devices visible (via Zigbee2MQTT).
**Troubleshooting:** Zigbee not working — check MQTT broker connection. HA not starting — check config directory permissions.

### 60-64: Readeck
**Enable:** `my.apps.readeck.enable = true;` DynamicUser sandbox.
**Verify:** Readeck web UI accessible. Test URL archiving.
**Troubleshooting:** Archiving fails — check network access from service. Verify DynamicUser permissions.

### 60-65: Matrix Conduit
**Enable:** `my.apps.matrix.enable = true;` Set server name and admin user.
**Verify:** `curl http://localhost:<port>/_matrix/client/versions` returns version info. Test with Element client.
**Troubleshooting:** Federation not working — check DNS SRV records. Database errors — verify PostgreSQL.

### 60-66: Miniflux RSS
**Enable:** `my.apps.miniflux.enable = true;` Socket-activated. PostgreSQL backend.
**Verify:** Miniflux web UI accessible. Test feed subscription. `systemctl status miniflux.socket` shows socket active.
**Troubleshooting:** Feed not updating — check network access. Database errors — verify PostgreSQL connection.

### 60-67: Linkding
**Enable:** `my.apps.linkding.enable = true;` SSO via Pocket-ID.
**Verify:** Linkding web UI accessible. Test bookmark creation.
**Troubleshooting:** SSO failing — check Pocket-ID OIDC configuration.

### 60-68: Monica CRM
**Enable:** `my.apps.monica.enable = true;` PostgreSQL backend.
**Verify:** Monica web UI accessible. Test contact creation.
**Troubleshooting:** Database migration failed — check PostgreSQL version compatibility.

### 60-69: Karakeep
**Enable:** `my.apps.karakeep.enable = true;` SSO-protected, AI tagging.
**Verify:** Karakeep web UI accessible. Test bookmark with AI tags.
**Troubleshooting:** AI tagging not working — check AI service connection.

### 60-70: Linkwarden
**Enable:** `my.apps.linkwarden.enable = true;` PostgreSQL backend. Caddy + SSO.
**Verify:** Linkwarden web UI accessible. Test URL archiving. `systemctl status linkwarden` shows running.
**Troubleshooting:** Archiving fails — check network access. PostgreSQL connection — verify database exists.

### 60-71: OliveTin
**Enable:** `my.apps.olivetin.enable = true;` Socket-activated. Define allowed commands and sudo rules.
**Verify:** OliveTin web UI accessible. Test predefined actions (system update, etc.). `systemctl status olivetin.socket` shows socket active.
**Troubleshooting:** Command not executing — check sudo rules. Socket not activating — verify wantedBy configuration.

### 60-72: Open WebUI
**Enable:** `my.apps.openWebui.enable = true;` Ollama must be running. GPU access via SupplementaryGroups.
**Verify:** Open WebUI accessible. Test chat with model. `journalctl -u open-webui` shows startup.
**Troubleshooting:** No GPU acceleration — verify render/video group membership. Ollama not connected — check OLLAMA_API_BASE_URL.

---

## Cross-Domain Interactions

- Depends on: Domain 00 (core, PostgreSQL), Domain 10 (network, Caddy, Pocket-ID), Domain 20 (secrets)
- Used by: Domain 40 (monitoring, health checks)
