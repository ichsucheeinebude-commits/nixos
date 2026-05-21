---
domain: 50
id: "NIXH-50-MED-003"
title: "Download Guide"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [media,download]
description: "Configure SABnzbd."
path: "docs/guides/GUIDE-52-download.md"
links:
  module: "modules/50-media/52-download.nix"
---

# Guide: Download Guide

```nix
my.media.downloads.enable = true;
```


---

## KB Nuggets

=== SABnzbd Master-Config
Usenet-Client mit VPN-Confinement. Download-Dir auf Tier B.完成后自动移动到 Tier C.

---
## SABnzbd MASTER-CONFIG (from KB)

---
title: 📚 SABnzbd MASTER-VARIABLE-LIST (v1.0)
category: architecture/reference
status: [ACTIVE-SSoT]
sources: [https://github.com/sabnzbd/sabnzbd (Code Extraction)]
---

# 📚 SABnzbd: Konfigurations-Referenz

AUTOMATION_GITHUB_TOKEN
CI
DISPLAY
GITHUB_REF
GITHUB_REF_NAME
HOME
MACOSX_DEPLOYMENT_TARGET
NOTARIZATION_PASS
NOTARIZATION_USER
PATHEXT
REDDIT_TOKEN
SIGNING_AUTH

## 🚀 SRE-Anwendung
SABnzbd wird in NixOS primär über \`services.sabnzbd\` gesteuert.
