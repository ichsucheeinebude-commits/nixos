# ADR-72: Open WebUI

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 60-apps  
**Module:** `72-open-webui.nix`

## Context

Ollama provides API access to local LLMs, but no user-friendly interface. Open WebUI fills this gap — chat interface, model management, all declaratively in NixOS.

## Decision

Implement **Open WebUI Pattern**:

1. **services.open-webui** — NixOS-native module.
2. **Ollama Integration** — Automatic OLLAMA_API_BASE_URL.
3. **Privacy Controls** — SCARF_NO_ANALYTICS, DO_NOT_TRACK, ANONYMIZED_TELEMETRY.
4. **DynamicUser Sandboxing** — No fixed user, strict security.
5. **GPU Access** — SupplementaryGroups for render/video (hardware acceleration).

## Consequences

### Positive
- User-friendly LLM interaction
- Strong systemd sandboxing
- Privacy-first configuration

### Negative
- Requires Ollama backend
- GPU access needs SupplementaryGroups
- Memory-intensive under heavy use

## SRE Standards

- DynamicUser = true (no persistent user)
- ProtectSystem = strict, ProtectHome = true
- SystemCallFilter = ["@system-service" "~@privileged"]
- SupplementaryGroups = ["render" "video"] for GPU access
- OOMScoreAdjust = 200 (can be killed under memory pressure)
