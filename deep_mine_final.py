#!/usr/bin/env python3
"""Final deep KB mining — inject ALL remaining KB knowledge into target files."""
import os, re, glob

KB = "/root/_kb"
T = "/root/nixos-work"

def rkb(p):
    f = os.path.join(KB, p)
    if not os.path.exists(f): return None
    try:
        c = open(f, encoding='utf-8', errors='replace').read()
        return None if c.strip() in ('%s','','---\n---') else c
    except: return None

def rt(p):
    f = os.path.join(T, p)
    return open(f, encoding='utf-8', errors='replace').read() if os.path.exists(f) else None

def wt(p, c):
    os.makedirs(os.path.dirname(os.path.join(T, p)), exist_ok=True)
    open(os.path.join(T, p), 'w', encoding='utf-8').write(c)

changed = 0

# ═══════════════════════════════════════════════════
# Caddy Encyclopedia (15-caddy)
# ═══════════════════════════════════════════════════
caddy_files = [
    "guides/GUIDE-Caddy-M1-Abrams.md",
    "guides/GUIDE-Caddy-Gateway-Mastery.md", 
    "guides/GUIDE-Caddy-Operations-Master.md",
    "services/caddy-migration-plan.md",
    "services/cloudflare-homeserver-setup.md",
]
adr15 = rt("docs/adr/ADR-15-caddy.md")
guide15 = rt("docs/guides/15-caddy.md")
for f in caddy_files:
    c = rkb(f)
    if c and adr15:
        # Extract meaningful sections
        sections = re.split(r'\n##+\s+', c)
        for s in sections:
            lines = s.strip().split('\n', 1)
            if len(lines) >= 2 and len(lines[1]) > 60:
                adr15 += f"\n### {lines[0].strip()}\n\n{lines[1].strip()[:1500]}\n"
    if c and guide15:
        sections = re.split(r'\n##+\s+', c)
        for s in sections:
            lines = s.strip().split('\n', 1)
            if len(lines) >= 2 and len(lines[1]) > 60:
                guide15 += f"\n### {lines[0].strip()}\n\n{lines[1].strip()[:1500]}\n"
if adr15: wt("docs/adr/ADR-15-caddy.md", adr15); changed += 1
if guide15: wt("docs/guides/15-caddy.md", guide15); changed += 1

# ═══════════════════════════════════════════════════
# PocketID Identity (17-pocket-id)
# ═══════════════════════════════════════════════════
pocketid = rkb("services/identity-pocketid-v4.2.md")
adr17 = rt("docs/adr/ADR-17-pocket-id.md")
guide17 = rt("docs/guides/17-pocket-id.md")
if pocketid:
    if adr17:
        adr17 += f"\n---\n## PocketID Identity Provider (from KB)\n\n{pocketid[:3000]}\n"
        wt("docs/adr/ADR-17-pocket-id.md", adr17); changed += 1
    if guide17:
        guide17 += f"\n---\n## PocketID Configuration (from KB)\n\n{pocketid[:3000]}\n"
        wt("docs/guides/17-pocket-id.md", guide17); changed += 1

# ═══════════════════════════════════════════════════
# Security Hardening Baseline (20-security)
# ═══════════════════════════════════════════════════
secbase = rkb("services/security-hardening-baseline.md")
adr21 = rt("docs/adr/ADR-21-kernel-hardening.md")
guide21 = rt("docs/guides/21-kernel-hardening.md")
if secbase:
    if adr21:
        adr21 += f"\n---\n## Security Hardening Baseline (from KB)\n\n{secbase[:2500]}\n"
        wt("docs/adr/ADR-21-kernel-hardening.md", adr21); changed += 1
    if guide21:
        guide21 += f"\n---\n## Security Hardening Baseline (from KB)\n\n{secbase[:2500]}\n"
        wt("docs/guides/21-kernel-hardening.md", guide21); changed += 1

# ═══════════════════════════════════════════════════
# Home Assistant (63-home-assistant)
# ═══════════════════════════════════════════════════
ha = rkb("services/service-automation-home-assistant.md")
guide63 = rt("docs/guides/63-home-assistant.md")
if ha and guide63:
    guide63 += f"\n---\n## Home Assistant Blueprint (from KB)\n\n{ha[:2500]}\n"
    wt("docs/guides/63-home-assistant.md", guide63); changed += 1

# ═══════════════════════════════════════════════════
# Media Stack Hardening (50-media)
# ═══════════════════════════════════════════════════
media_hard = rkb("services/media-stack-hardening.md")
guide50 = rt("docs/guides/50-lib-media.md")
if media_hard and guide50:
    guide50 += f"\n---\n## Media Stack Hardening (from KB)\n\n{media_hard[:2000]}\n"
    wt("docs/guides/50-lib-media.md", guide50); changed += 1

# ═══════════════════════════════════════════════════
# n8n Security (61-n8n)
# ═══════════════════════════════════════════════════
n8n_sec = rkb("learnings/n8n-security-hardening.md")
adr61 = rt("docs/adr/ADR-61-n8n.md")
if n8n_sec and adr61:
    adr61 += f"\n---\n## n8n Security Hardening (from KB)\n\n{n8n_sec[:2000]}\n"
    wt("docs/adr/ADR-61-n8n.md", adr61); changed += 1

# ═══════════════════════════════════════════════════
# SRE Audit v4.2 (90-policy)
# ═══════════════════════════════════════════════════
sre42 = rkb("learnings/sre-audit-v4.2.md")
adr91 = rt("docs/adr/ADR-91-architecture-rules.md")
if sre42 and adr91:
    adr91 += f"\n---\n## SRE Audit v4.2 Findings (from KB)\n\n{sre42[:2500]}\n"
    wt("docs/adr/ADR-91-architecture-rules.md", adr91); changed += 1

# ═══════════════════════════════════════════════════
# Impermanence / Disko learnings (30-storage)
# ═══════════════════════════════════════════════════
disko = rkb("learnings/nix-comm-disko.md")
impermanence = rkb("learnings/nix-comm-impermanence.md")
adr32 = rt("docs/adr/ADR-32-impermanence.md")
if (disko or impermanence) and adr32:
    if disko: adr32 += f"\n---\n## Disko Integration (from KB)\n\n{disko[:1500]}\n"
    if impermanence: adr32 += f"\n---\n## Impermanence Pattern (from KB)\n\n{impermanence[:1500]}\n"
    wt("docs/adr/ADR-32-impermanence.md", adr32); changed += 1

# ═══════════════════════════════════════════════════
# best-of-nix.md key sections → 90-policy (forbidden tech / architecture rules)
# ═══════════════════════════════════════════════════
bon = rkb("best-of-nix.md")
if bon:
    # Extract NixOS Modules section
    match = re.search(r'## NixOS Modules\n(.*?)## [A-Z]', bon, re.DOTALL)
    if match and adr91:
        adr91 += f"\n---\n## Top NixOS Community Projects (from best-of-nix)\n\n{match.group(1)[:2000]}\n"
        wt("docs/adr/ADR-91-architecture-rules.md", adr91); changed += 1

# ═══════════════════════════════════════════════════
# Monitoring Dashboard Comparison (40-monitoring)
# ═══════════════════════════════════════════════════
dash_comp = rkb("services/dashboard-comparison-v4.2.md")
guide40 = rt("docs/guides/40-gatus.md")
if dash_comp and guide40:
    guide40 += f"\n---\n## Dashboard Comparison Analysis (from KB)\n\n{dash_comp[:2000]}\n"
    wt("docs/guides/40-gatus.md", guide40); changed += 1

# ═══════════════════════════════════════════════════
# SSH Rescue (13-ssh-rescue)
# ═══════════════════════════════════════════════════
ssh_rescue = rkb("services/service-ssh-rescue-window.md")
guide13 = rt("docs/guides/13-ssh-rescue.md")
if ssh_rescue and guide13:
    guide13 += f"\n---\n## SSH Rescue Window (from KB)\n\n{ssh_rescue[:2000]}\n"
    wt("docs/guides/13-ssh-rescue.md", guide13); changed += 1

# ═══════════════════════════════════════════════════
# Boot Safeguard (04-boot-safeguards)
# ═══════════════════════════════════════════════════
boot = rkb("services/service-boot-safeguard.md")
guide04 = rt("docs/guides/04-boot-safeguards.md")
if boot and guide04:
    guide04 += f"\n---\n## Boot Safeguard (from KB)\n\n{boot[:2000]}\n"
    wt("docs/guides/04-boot-safeguards.md", guide04); changed += 1

# ═══════════════════════════════════════════════════
# Memory Tuning HAL (02-nix-tuning)
# ═══════════════════════════════════════════════════
mem = rkb("services/memory-tuning-hal.md")
guide02 = rt("docs/guides/02-nix-tuning.md")
if mem and guide02:
    guide02 += f"\n---\n## Memory Tuning HAL (from KB)\n\n{mem[:1500]}\n"
    wt("docs/guides/02-nix-tuning.md", guide02); changed += 1

# ═══════════════════════════════════════════════════
# DNS Automation (16-dns-automation)
# ═══════════════════════════════════════════════════
dns = rkb("services/service-dns-automation-guard.md")
guide16 = rt("docs/guides/16-dns-automation.md")
if dns and guide16:
    guide16 += f"\n---\n## DNS Automation Guard (from KB)\n\n{dns[:2000]}\n"
    wt("docs/guides/16-dns-automation.md", guide16); changed += 1

# ═══════════════════════════════════════════════════
# Config Merger Bridge (01-configs-registry)
# ═══════════════════════════════════════════════════
merger = rkb("services/service-config-merger-bridge.md")
guide01 = rt("docs/guides/01-configs-registry.md")
if merger and guide01:
    guide01 += f"\n---\n## Config Merger Bridge (from KB)\n\n{merger[:1500]}\n"
    wt("docs/guides/01-configs-registry.md", guide01); changed += 1

# ═══════════════════════════════════════════════════
# Paperless NGX Master Config (60-paperless)
# ═══════════════════════════════════════════════════
paperless = rkb("guides/MASTER-CONFIG-PAPERLESS-NGX.md")
adr60 = rt("docs/adr/ADR-60-paperless.md")
if paperless and adr60:
    adr60 += f"\n---\n## Paperless-ngx MASTER-CONFIG (from KB)\n\n{paperless[:2500]}\n"
    wt("docs/adr/ADR-60-paperless.md", adr60); changed += 1

# ═══════════════════════════════════════════════════
# Vaultwarden Master Config (62-vaultwarden)
# ═══════════════════════════════════════════════════
vw = rkb("guides/MASTER-CONFIG-VAULTWARDEN.md")
adr62 = rt("docs/adr/ADR-62-vaultwarden.md")
if vw and adr62:
    adr62 += f"\n---\n## Vaultwarden MASTER-CONFIG (from KB)\n\n{vw[:2500]}\n"
    wt("docs/adr/ADR-62-vaultwarden.md", adr62); changed += 1

# ═══════════════════════════════════════════════════
# SABNZBD Master Config (52-download)
# ═══════════════════════════════════════════════════
sab = rkb("guides/MASTER-CONFIG-SABNZBD.md")
guide52 = rt("docs/guides/52-download.md")
if sab and guide52:
    guide52 += f"\n---\n## SABnzbd MASTER-CONFIG (from KB)\n\n{sab[:2500]}\n"
    wt("docs/guides/52-download.md", guide52); changed += 1

# ═══════════════════════════════════════════════════
# Radarr Master Config (57-radarr)
# ═══════════════════════════════════════════════════
radarr = rkb("guides/MASTER-CONFIG-RADARR.md")
guide57 = rt("docs/guides/57-radarr.md")
if radarr and guide57:
    guide57 += f"\n---\n## Radarr MASTER-CONFIG (from KB)\n\n{radarr[:2500]}\n"
    wt("docs/guides/57-radarr.md", guide57); changed += 1

# ═══════════════════════════════════════════════════
# Seerr Master Config (54-discovery)
# ═══════════════════════════════════════════════════
seerr = rkb("guides/MASTER-CONFIG-SEERR.md")
guide54 = rt("docs/guides/54-discovery.md")
if seerr and guide54:
    guide54 += f"\n---\n## Jellyseerr MASTER-CONFIG (from KB)\n\n{seerr[:2500]}\n"
    wt("docs/guides/54-discovery.md", guide54); changed += 1

# ═══════════════════════════════════════════════════
# Audiobookshelf Master Config (54-discovery / 53-streaming)
# ═══════════════════════════════════════════════════
abs = rkb("guides/MASTER-CONFIG-AUDIOBOOKSHELF.md")
guide53 = rt("docs/guides/53-streaming.md")
if abs and guide53:
    guide53 += f"\n---\n## Audiobookshelf MASTER-CONFIG (from KB)\n\n{abs[:2500]}\n"
    wt("docs/guides/53-streaming.md", guide53); changed += 1

# ═══════════════════════════════════════════════════
# N8N Master Config (61-n8n)
# ═══════════════════════════════════════════════════
n8n = rkb("guides/MASTER-CONFIG-N8N.md")
guide61 = rt("docs/guides/61-n8n.md")
if n8n and guide61:
    guide61 += f"\n---\n## n8n MASTER-CONFIG (from KB)\n\n{n8n[:2500]}\n"
    wt("docs/guides/61-n8n.md", guide61); changed += 1

# ═══════════════════════════════════════════════════
# Homepage Master Config (40-monitoring)
# ═══════════════════════════════════════════════════
homepage = rkb("guides/MASTER-CONFIG-HOMEPAGE.md")
if homepage:
    # Could go into any monitoring guide
    guide40b = rt("docs/guides/40-gatus.md")
    if guide40b:
        guide40b += f"\n---\n## Homepage Dashboard MASTER-CONFIG (from KB)\n\n{homepage[:2000]}\n"
        wt("docs/guides/40-gatus.md", guide40b); changed += 1

# ═══════════════════════════════════════════════════
# SOPS learnings (22-secrets)
# ═══════════════════════════════════════════════════
sops = rkb("learnings/nix-comm-sops.md")
guide22 = rt("docs/guides/22-secrets.md")
if sops and guide22:
    guide22 += f"\n---\n## SOPS Integration (from KB)\n\n{sops[:2000]}\n"
    wt("docs/guides/22-secrets.md", guide22); changed += 1

# ═══════════════════════════════════════════════════
# Disk Discovery HAL (30-storage)
# ═══════════════════════════════════════════════════
disk_hal = rkb("services/disk-discovery-hal.md")
guide33 = rt("docs/guides/33-storage-policy.md")
if disk_hal and guide33:
    guide33 += f"\n---\n## Disk Discovery HAL (from KB)\n\n{disk_hal[:2000]}\n"
    wt("docs/guides/33-storage-policy.md", guide33); changed += 1

# ═══════════════════════════════════════════════════
# State Streaming Backup (30-storage)
# ═══════════════════════════════════════════════════
state_backup = rkb("services/state-streaming-backup.md")
guide31b = rt("docs/guides/31-backup.md")
if state_backup and guide31b:
    guide31b += f"\n---\n## State Streaming Backup (from KB)\n\n{state_backup[:2000]}\n"
    wt("docs/guides/31-backup.md", guide31b); changed += 1

# ═══════════════════════════════════════════════════
# Media Automation (50-media)
# ═══════════════════════════════════════════════════
media_auto = rkb("services/media-stack-automation-v4.2.md")
guide51b = rt("docs/guides/51-arr-stack.md")
if media_auto and guide51b:
    guide51b += f"\n---\n## Media Stack Automation (from KB)\n\n{media_auto[:2000]}\n"
    wt("docs/guides/51-arr-stack.md", guide51b); changed += 1

# ═══════════════════════════════════════════════════
# Monitoring Scrutiny (43-scrutiny)
# ═══════════════════════════════════════════════════
scrutiny_svc = rkb("services/service-monitoring-scrutiny.md")
guide43 = rt("docs/guides/43-scrutiny.md")
if scrutiny_svc and guide43:
    guide43 += f"\n---\n## Scrutiny Monitoring (from KB)\n\n{scrutiny_svc[:2000]}\n"
    wt("docs/guides/43-scrutiny.md", guide43); changed += 1

# ═══════════════════════════════════════════════════
# Monitoring Cockpit (40-monitoring)
# ═══════════════════════════════════════════════════
mon_cockpit = rkb("services/service-monitoring-cockpit.md")
guide41 = rt("docs/guides/41-netdata.md")
if mon_cockpit and guide41:
    guide41 += f"\n---\n## Monitoring Cockpit (from KB)\n\n{mon_cockpit[:2000]}\n"
    wt("docs/guides/41-netdata.md", guide41); changed += 1

# ═══════════════════════════════════════════════════
# Vaultwarden Service (62-vaultwarden)
# ═══════════════════════════════════════════════════
vw_svc = rkb("services/service-apps-vaultwarden.md")
guide62b = rt("docs/guides/62-vaultwarden.md")
if vw_svc and guide62b:
    guide62b += f"\n---\n## Vaultwarden Service Config (from KB)\n\n{vw_svc[:1500]}\n"
    wt("docs/guides/62-vaultwarden.md", guide62b); changed += 1

# ═══════════════════════════════════════════════════
# Matrix Conduit Service (65-matrix-conduit)
# ═══════════════════════════════════════════════════
matrix_svc = rkb("services/service-apps-matrix-conduit.md")
guide65b = rt("docs/guides/65-matrix-conduit.md")
if matrix_svc and guide65b:
    guide65b += f"\n---\n## Matrix Conduit Service (from KB)\n\n{matrix_svc[:2000]}\n"
    wt("docs/guides/65-matrix-conduit.md", guide65b); changed += 1

# ═══════════════════════════════════════════════════
# Monica Service (68-monica)
# ═══════════════════════════════════════════════════
monica = rkb("services/service-apps-monica.md")
guide68 = rt("docs/guides/68-monica.md")
if monica and guide68:
    guide68 += f"\n---\n## Monica CRM Service (from KB)\n\n{monica[:1500]}\n"
    wt("docs/guides/68-monica.md", guide68); changed += 1

# ═══════════════════════════════════════════════════
# Karakeep Service (69-karakeep)
# ═══════════════════════════════════════════════════
karakeep = rkb("services/service-apps-karakeep.md")
guide69 = rt("docs/guides/69-karakeep.md")
if karakeep and guide69:
    guide69 += f"\n---\n## Karakeep Service (from KB)\n\n{karakeep[:1500]}\n"
    wt("docs/guides/69-karakeep.md", guide69); changed += 1

# ═══════════════════════════════════════════════════
# n8n Service (61-n8n)
# ═══════════════════════════════════════════════════
n8n_svc = rkb("services/service-automation-n8n.md")
guide61b = rt("docs/guides/61-n8n.md")
if n8n_svc and guide61b:
    guide61b += f"\n---\n## n8n Automation Service (from KB)\n\n{n8n_svc[:2000]}\n"
    wt("docs/guides/61-n8n.md", guide61b); changed += 1

print(f"\nFinal deep mining complete: {changed} files enhanced")
