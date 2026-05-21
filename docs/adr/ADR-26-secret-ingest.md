# ADR-26: Secret Ingest Pipeline

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 20-security  
**Module:** `26-secret-ingest.nix`

## Context

Secrets must enter the system securely and in a versioned way. Instead of manually operating SOPS, a landing zone directory is watched. When a file is dropped there, it is automatically processed.

## Decision

Implement **Secret Ingest Pattern**:

1. **systemd.path Watcher** — Monitors directory for new files.
2. **One-Shot Service** — Triggered when files are detected.
3. **Python Processor** — Can handle complex validation/transformation.
4. **SOPS Integration** — Only processes SOPS-encrypted files.

## Consequences

### Positive
- Automated secret processing
- Audit trail via moved-to-processed directory
- No manual SOPS commands needed

### Negative
- Requires directory permission management
- Python dependency for processing
- Must ensure SOPS key is available

## SRE Standards

- Landing zone: /etc/nixos/secret-landing-zone (Root-only)
- Watcher is MakeDirectory = true (creates directory if missing)
- Service is Type = oneshot (runs once per trigger)
