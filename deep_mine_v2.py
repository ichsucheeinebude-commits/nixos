#!/usr/bin/env python3
"""Deep KB Mining: Read KB files, extract substance, inject into ADRs/Guides/Modules.
Domain-by-domain, all at once. Creates missing files, enhances existing ones."""

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
# 00-CORE: Deep injection
# ═══════════════════════════════════════════════════
core_kb = {}
for f in ["adr/den-framework-foundation.md", "adr/nixhome-architecture.md",
           "guides/GUIDE-Aviation-Grade-Hardening-srvos.md",
           "guides/GUIDE-Binary-Cache-Optimization.md",
           "guides/GUIDE-Nixpkgs-Engine-Mastery.md",
           "guides/GUIDE-Kernel-Mastery-Hardening.md",
           "guides/GUIDE-Nix-Dry-Refactoring.md",
           "guides/GUIDE-Service-Hardening-Sandboxing.md",
           "learnings/sre-audit-v4.2.md", "learnings/sre-audit-v2.3.md"]:
    c = rkb(f)
    if c: core_kb[f] = c

# Extract sections from KB files
def extract_sections(text):
    parts = re.split(r'\n##+\s+', text)
    result = []
    for p in parts:
        lines = p.strip().split('\n', 1)
        if len(lines) >= 2 and len(lines[1]) > 40:
            result.append((lines[0].strip(), lines[1].strip()))
    return result

# Enhance 00-core ADR
adr00 = rt("docs/adr/ADR-00-principles.md")
if adr00 and "Aviation-Grade" not in adr00:
    sections = extract_sections(core_kb.get("adr/den-framework-foundation.md", ""))
    content = ""
    for h, b in sections[:5]:
        content += f"\n### {h}\n\n{b}\n"
    adr00 = adr00.replace("\n## Decision\n", "\n## Decision\n" + content)
    wt("docs/adr/ADR-00-principles.md", adr00)
    changed += 1

# Enhance 00-core Guide
guide00 = rt("docs/guides/00-principles.md")
if guide00 and "Aviation-Grade" not in guide00:
    sections = extract_sections(core_kb.get("guides/GUIDE-Aviation-Grade-Hardening-srvos.md", ""))
    content = ""
    for h, b in sections[:5]:
        content += f"\n### {h}\n\n{b}\n"
    guide00 = guide00.replace("\n## Usage\n", "\n## Usage\n" + content)
    wt("docs/guides/00-principles.md", guide00)
    changed += 1

# Enhance 02-nix-tuning
guide02 = rt("docs/guides/02-nix-tuning.md")
if guide02 and "binary-cache" not in guide02.lower():
    sections = extract_sections(core_kb.get("guides/GUIDE-Binary-Cache-Optimization.md", ""))
    content = ""
    for h, b in sections[:4]:
        content += f"\n### {h}\n\n{b}\n"
    guide02 += f"\n---\n## KB Nuggets\n{content}\n"
    wt("docs/guides/02-nix-tuning.md", guide02)
    changed += 1

adr02 = rt("docs/adr/ADR-02-nix-tuning.md")
if adr02:
    sections = extract_sections(core_kb.get("guides/GUIDE-Nixpkgs-Engine-Mastery.md", ""))
    content = ""
    for h, b in sections[:4]:
        content += f"\n### {h}\n\n{b}\n"
    adr02 += f"\n---\n## KB Nuggets\n{content}\n"
    wt("docs/adr/ADR-02-nix-tuning.md", adr02)
    changed += 1

# Enhance 03-hardware-profile
adr03 = rt("docs/adr/ADR-03-hardware-profile.md")
if adr03:
    hw = rkb("adr/hardware-spec-q958.md")
    if hw and len(hw) > 100:
        adr03 += f"\n---\n## Hardware Reference (from KB)\n\n{hw[:2000]}\n"
        wt("docs/adr/ADR-03-hardware-profile.md", adr03)
        changed += 1

# Enhance 21-kernel-hardening
adr21 = rt("docs/adr/ADR-21-kernel-hardening.md")
if adr21:
    sections = extract_sections(core_kb.get("guides/GUIDE-Kernel-Mastery-Hardening.md", ""))
    content = ""
    for h, b in sections[:4]:
        content += f"\n### {h}\n\n{b}\n"
    adr21 += f"\n---\n## KB Nuggets\n{content}\n"
    wt("docs/adr/ADR-21-kernel-hardening.md", adr21)
    changed += 1

# ═══════════════════════════════════════════════════
# 10-NETWORK: Deep injection (Caddy, SSH, DNS)
# ═══════════════════════════════════════════════════
net_kb = {}
for f in ["guides/GUIDE-Caddy-M1-Abrams.md", "guides/GUIDE-Caddy-Gateway-Mastery.md",
           "guides/GUIDE-Caddy-Operations-Master.md",
           "guides/GUIDE-SSH-Infrastructure-Mastery.md",
           "guides/GUIDE-Nftables-Firewall-Mastery.md",
           "guides/GUIDE-Blocky-Performance-DNS.md",
           "services/caddy-migration-plan.md",
           "services/cloudflare-homeserver-setup.md"]:
    c = rkb(f)
    if c: net_kb[f] = c

# Enhance 15-caddy ADR
adr15 = rt("docs/adr/ADR-15-caddy.md")
if adr15:
    for src in ["guides/GUIDE-Caddy-M1-Abrams.md", "services/caddy-migration-plan.md"]:
        sections = extract_sections(net_kb.get(src, ""))
        for h, b in sections[:3]:
            adr15 += f"\n### {h}\n\n{b}\n"
    wt("docs/adr/ADR-15-caddy.md", adr15)
    changed += 1

# Enhance 15-caddy Guide
guide15 = rt("docs/guides/15-caddy.md")
if guide15:
    for src in ["guides/GUIDE-Caddy-Gateway-Mastery.md", "guides/GUIDE-Caddy-Operations-Master.md"]:
        sections = extract_sections(net_kb.get(src, ""))
        for h, b in sections[:4]:
            guide15 += f"\n### {h}\n\n{b}\n"
    wt("docs/guides/15-caddy.md", guide15)
    changed += 1

# Enhance 12-ssh
adr12 = rt("docs/adr/ADR-12-ssh.md")
if adr12:
    sections = extract_sections(net_kb.get("guides/GUIDE-SSH-Infrastructure-Mastery.md", ""))
    for h, b in sections[:3]:
        adr12 += f"\n### {h}\n\n{b}\n"
    wt("docs/adr/ADR-12-ssh.md", adr12)
    changed += 1

# Enhance 11-firewall
guide11 = rt("docs/guides/11-firewall.md")
if guide11:
    sections = extract_sections(net_kb.get("guides/GUIDE-Nftables-Firewall-Mastery.md", ""))
    for h, b in sections[:3]:
        guide11 += f"\n### {h}\n\n{b}\n"
    wt("docs/guides/11-firewall.md", guide11)
    changed += 1

# Enhance 14-blocky
guide14 = rt("docs/guides/14-blocky.md")
if guide14:
    sections = extract_sections(net_kb.get("guides/GUIDE-Blocky-Performance-DNS.md", ""))
    for h, b in sections[:3]:
        guide14 += f"\n### {h}\n\n{b}\n"
    wt("docs/guides/14-blocky.md", guide14)
    changed += 1

# ═══════════════════════════════════════════════════
# 20-SECURITY: Deep injection
# ═══════════════════════════════════════════════════
sec_kb = {}
for f in ["guides/MASTER-CONFIG-FAIL2BAN.md", "guides/MASTER-CONFIG-FAIL2BAN-ENDPOINTS.md",
           "guides/GUIDE-Landlock-Isolation-Mastery.md",
           "learnings/nix-comm-sops.md"]:
    c = rkb(f)
    if c: sec_kb[f] = c

# Enhance 20-fail2ban Guide
guide20 = rt("docs/guides/20-fail2ban.md")
if guide20:
    endpoints = rkb("guides/MASTER-CONFIG-FAIL2BAN-ENDPOINTS.md")
    if endpoints:
        # Extract the filter and action lists
        guide20 += f"\n---\n## Available Fail2ban Filters & Actions (from KB)\n\n{endpoints[:3000]}\n"
    wt("docs/guides/20-fail2ban.md", guide20)
    changed += 1

# Enhance 22-secrets ADR
adr22 = rt("docs/adr/ADR-22-secrets.md")
if adr22:
    sops = rkb("learnings/nix-comm-sops.md")
    if sops and len(sops) > 100:
        adr22 += f"\n---\n## SOPS Integration (from KB)\n\n{sops[:2000]}\n"
    wt("docs/adr/ADR-22-secrets.md", adr22)
    changed += 1

# ═══════════════════════════════════════════════════
# 30-STORAGE: Deep injection
# ═══════════════════════════════════════════════════
stor_kb = {}
for f in ["guides/GUIDE-ABC-Storage-Tiering.md", "guides/GUIDE-Blank-Snapshot-Persistence.md",
           "guides/MASTER-CONFIG-RESTIC.md", "guides/MASTER-CONFIG-RCLONE.md",
           "learnings/nix-comm-disko.md", "learnings/nix-comm-impermanence.md"]:
    c = rkb(f)
    if c: stor_kb[f] = c

guide30 = rt("docs/guides/30-storage.md")
if guide30:
    sections = extract_sections(stor_kb.get("guides/GUIDE-ABC-Storage-Tiering.md", ""))
    for h, b in sections[:4]:
        guide30 += f"\n### {h}\n\n{b}\n"
    wt("docs/guides/30-storage.md", guide30)
    changed += 1

guide31 = rt("docs/guides/31-backup.md")
if guide31:
    restic = rkb("guides/MASTER-CONFIG-RESTIC.md")
    if restic:
        guide31 += f"\n---\n## Restic MASTER-CONFIG (from KB)\n\n{restic[:2500]}\n"
    wt("docs/guides/31-backup.md", guide31)
    changed += 1

guide32 = rt("docs/guides/32-impermanence.md")
if guide32:
    imp = rkb("guides/GUIDE-Blank-Snapshot-Persistence.md")
    if imp:
        sections = extract_sections(imp)
        for h, b in sections[:4]:
            guide32 += f"\n### {h}\n\n{b}\n"
    wt("docs/guides/32-impermanence.md", guide32)
    changed += 1

# ═══════════════════════════════════════════════════
# 40-MONITORING: Deep injection
# ═══════════════════════════════════════════════════
mon_kb = {}
for f in ["guides/GUIDE-Monitoring-Hub-Gatus.md", "guides/MASTER-CONFIG-GATUS.md",
           "guides/MASTER-CONFIG-HOMEPAGE.md",
           "guides/GUIDE-System-Monitoring-Telemetry.md"]:
    c = rkb(f)
    if c: mon_kb[f] = c

guide40 = rt("docs/guides/40-gatus.md")
if guide40:
    gatus = rkb("guides/MASTER-CONFIG-GATUS.md")
    if gatus:
        guide40 += f"\n---\n## Gatus MASTER-CONFIG (from KB)\n\n{gatus[:2500]}\n"
    wt("docs/guides/40-gatus.md", guide40)
    changed += 1

# ═══════════════════════════════════════════════════
# 50-MEDIA: Deep injection
# ═══════════════════════════════════════════════════
media_kb = {}
for f in ["guides/GUIDE-Intel-QuickSync-NixOS.md", "guides/GUIDE-Hardware-Acceleration-DeepDive.md",
           "guides/GUIDE-Media-Mastery-Jellyfin.md",
           "guides/MASTER-CONFIG-SEERR.md", "guides/MASTER-CONFIG-RADARR.md",
           "guides/MASTER-CONFIG-ARR-STACK.md", "guides/MASTER-CONFIG-SABNZBD.md"]:
    c = rkb(f)
    if c: media_kb[f] = c

guide55 = rt("docs/guides/55-jellyfin.md")
if guide55:
    qs = rkb("guides/GUIDE-Intel-QuickSync-NixOS.md")
    if qs:
        guide55 += f"\n---\n## QuickSync Configuration (from KB)\n\n{qs[:2500]}\n"
    wt("docs/guides/55-jellyfin.md", guide55)
    changed += 1

guide51 = rt("docs/guides/51-arr-stack.md")
if guide51:
    arr = rkb("guides/MASTER-CONFIG-ARR-STACK.md")
    if arr:
        guide51 += f"\n---\n## ARR Stack MASTER-CONFIG (from KB)\n\n{arr[:2500]}\n"
    wt("docs/guides/51-arr-stack.md", guide51)
    changed += 1

# ═══════════════════════════════════════════════════
# 60-APPS: Deep injection
# ═══════════════════════════════════════════════════
apps_kb = {}
for f in ["guides/GUIDE-Paperless-Master-Config.md", "guides/MASTER-CONFIG-PAPERLESS-NGX.md",
           "guides/MASTER-CONFIG-VAULTWARDEN.md", "guides/MASTER-CONFIG-N8N.md",
           "guides/GUIDE-Conduit-Master-Config.md"]:
    c = rkb(f)
    if c: apps_kb[f] = c

guide60 = rt("docs/guides/60-paperless.md")
if guide60:
    paperless = rkb("guides/GUIDE-Paperless-Master-Config.md")
    if paperless:
        guide60 += f"\n---\n## Paperless MASTER-CONFIG (from KB)\n\n{paperless[:2500]}\n"
    wt("docs/guides/60-paperless.md", guide60)
    changed += 1

guide62 = rt("docs/guides/62-vaultwarden.md")
if guide62:
    vw = rkb("guides/MASTER-CONFIG-VAULTWARDEN.md")
    if vw:
        guide62 += f"\n---\n## Vaultwarden MASTER-CONFIG (from KB)\n\n{vw[:2500]}\n"
    wt("docs/guides/62-vaultwarden.md", guide62)
    changed += 1

guide61 = rt("docs/guides/61-n8n.md")
if guide61:
    n8n = rkb("guides/MASTER-CONFIG-N8N.md")
    if n8n:
        guide61 += f"\n---\n## n8n MASTER-CONFIG (from KB)\n\n{n8n[:2500]}\n"
    wt("docs/guides/61-n8n.md", guide61)
    changed += 1

guide65 = rt("docs/guides/65-matrix-conduit.md")
if guide65:
    conduit = rkb("guides/GUIDE-Conduit-Master-Config.md")
    if conduit:
        guide65 += f"\n---\n## Conduit MASTER-CONFIG (from KB)\n\n{conduit[:2500]}\n"
    wt("docs/guides/65-matrix-conduit.md", guide65)
    changed += 1

# ═══════════════════════════════════════════════════
# 90-POLICY: Deep injection
# ═══════════════════════════════════════════════════
pol_kb = {}
for f in ["learnings/FINDINGS-REGISTRY.md", "learnings/sre-audit-v4.2.md",
           "learnings/sre-audit-v2.3.md"]:
    c = rkb(f)
    if c: pol_kb[f] = c

guide90 = rt("docs/guides/90-forbidden-tech.md")
if guide90:
    findings = rkb("learnings/FINDINGS-REGISTRY.md")
    if findings:
        guide90 += f"\n---\n## Findings Registry (from KB)\n\n{findings[:2000]}\n"
    wt("docs/guides/90-forbidden-tech.md", guide90)
    changed += 1

# ═══════════════════════════════════════════════════
# SUMMARY
# ═══════════════════════════════════════════════════
print(f"\nDeep injection complete: {changed} files enhanced")
print(f"Files touched:")
for root, dirs, files in os.walk(T):
    for f in files:
        if f.endswith(('.md', '.nix')):
            full = os.path.join(root, f)
            if os.path.getmtime(full) > os.path.getmtime(os.path.join(T, '.git')):
                print(f"  {os.path.relpath(full, T)}")
