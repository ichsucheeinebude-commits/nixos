# ADR-25: ClamAV Antivirus Scanning

**Status:** Accepted  
**Date:** 2026-05-21  
**Domain:** 20-security  
**Module:** `25-clamav.nix`

## Context

Even on Linux servers, malware protection can be useful — especially when files are shared with Windows clients (SMB, WebDAV) or downloads from untrusted sources are processed.

## Decision

Implement **ClamAV Pattern**:

1. **Daemon + Updater** — Runs permanently, updates virus signatures.
2. **Weekly Scan** — Saturday 03:00, scans /home, /var/lib, /etc.
3. **Resource Limits** — Low CPU/IO priority (Weight=20, idle scheduling).
4. **Media Exclusions** — /mnt/media and downloads excluded.

## Consequences

### Positive
- Malware detection for shared files
- Scheduled scanning during off-hours
- Minimal performance impact

### Negative
- Weekly disk I/O during scan
- Signature database consumes disk space
- May produce false positives

## SRE Standards

- Scan interval: Weekly, not Daily (performance)
- CPUWeight = 20 (of 100), IOWeight = 20 — minimal impact
- MaxFileSize = 50M, MaxScanSize = 100M — resource bounded
