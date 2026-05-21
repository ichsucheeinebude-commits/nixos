# Open WebUI — LLM Chat Interface

**Module:** `modules/60-apps/72-open-webui.nix`  
**Domain:** 60-apps  
**Complexity:** ⭐⭐

## Overview

User-friendly WebUI for interacting with local LLMs via Ollama, with privacy controls and DynamicUser sandboxing.

## Enable

```nix
my.apps.openWebui.enable = true;
```

## Access

Available at: `https://ai.<domain>`

## Ollama Integration

By default, connects to Ollama at `http://127.0.0.1:11434`. Configure with:

```nix
my.apps.openWebui.ollamaPort = 11434;
my.apps.openWebui.ollamaUrl = "http://127.0.0.1:11434";
```

## Privacy Controls

- SCARF_NO_ANALYTICS = True
- DO_NOT_TRACK = True
- ANONYMIZED_TELEMETRY = False

## Sandboxing

- DynamicUser = true
- ProtectSystem = strict
- ProtectHome = true
- SupplementaryGroups = ["render" "video"] (GPU access)
- OOMScoreAdjust = 200
