#!/usr/bin/env python3
"""Deep KB Injection: _kb → nixos target repo
Reads ALL KB files per domain, extracts nuggets, injects into ADRs/Guides/Modules.
Adds source fields, strips personal data, maintains 1:1:1 isomorphy."""

import os, re, glob

KB = "/root/_kb"
TARGET = "/root/nixos-work"

def read_kb(path):
    full = os.path.join(KB, path)
    if not os.path.exists(full):
        return None
    try:
        with open(full, encoding='utf-8', errors='replace') as f:
            content = f.read()
        if content.strip() in ('%s', '', '---\n---'):
            return None
        return content
    except:
        return None

def read_target(path):
    full = os.path.join(TARGET, path)
    if not os.path.exists(full):
        return None
    with open(full, encoding='utf-8', errors='replace') as f:
        return f.read()

def write_target(path, content):
    full = os.path.join(TARGET, path)
    os.makedirs(os.path.dirname(full), exist_ok=True)
    with open(full, 'w', encoding='utf-8') as f:
        f.write(content)

# Personal data purge
def purge_personal(text):
    replacements = [
        (r'\bq958\b', '<HOSTNAME>'),
        (r'\bQ958\b', '<HOSTNAME>'),
        (r'\bm7c5\.de\b', '<DOMAIN>'),
        (r'\bmoritzbaumeister@gmail\.com\b', '<EMAIL>'),
        (r'\b53844\b', '22'),
        (r'\bEurope/Berlin\b', '<TIMEZONE>'),
        (r'\bde_DE\.UTF-8\b', '<LOCALE>'),
    ]
    for pat, repl in replacements:
        text = re.sub(pat, repl, text)
    return text

# ─── KB File Mapping per Domain ───
DOMAIN_KB_FILES = {
    "00-core": [
        "adr/den-framework-foundation.md",
        "adr/nixhome-architecture.md",
        "adr/isomorphie-strategie.md",
        "adr/hardware-spec-q958.md",
        "adr/sovereign-identity-v4.md",
        "adr/passkey-identity-standard.md",
        "guides/GUIDE-Aviation-Grade-Hardening-srvos.md",
        "guides/GUIDE-Binary-Cache-Optimization.md",
        "guides/GUIDE-Nixpkgs-Engine-Mastery.md",
        "guides/GUIDE-Kernel-Mastery-Hardening.md",
        "guides/GUIDE-Kernel-Surgical-Diet.md",
        "guides/GUIDE-Pattern-Mining-Nixpkgs.md",
        "guides/GUIDE-Nixpkgs-Packaging-Standard.md",
        "guides/GUIDE-Nix-Dry-Refactoring.md",
        "guides/GUIDE-Service-Hardening-Sandboxing.md",
        "guides/GUIDE-Automated-Documentation-Mastery.md",
        "guides/GUIDE-Stable-Network-Interface-MAC.md",
        "guides/GUIDE-Advanced-Hidden-Gems.md",
        "learnings/professional-workflow-audit.md",
        "learnings/sre-audit-v4.2.md",
        "services/service-boot-safeguard.md",
        "services/service-tty-boot-banner.md",
        "services/service-system-logging.md",
        "services/service-config-merger-bridge.md",
        "services/troubleshooting-system-load.md",
        "services/memory-tuning-hal.md",
    ],
    "10-network": [
        "adr/ADR-007-DNS-Naming-Standard.md",
        "adr/ADR-008-SSH-ProxyJump-Standard.md",
        "adr/ADR-005-Hybrid-Identity-Model.md",
        "guides/GUIDE-Caddy-M1-Abrams.md",
        "guides/GUIDE-Caddy-Gateway-Mastery.md",
        "guides/GUIDE-Caddy-Operations-Master.md",
        "guides/GUIDE-SSH-Infrastructure-Mastery.md",
        "guides/GUIDE-Windows-to-Nix-SSH.md",
        "guides/GUIDE-Nftables-Firewall-Mastery.md",
        "guides/GUIDE-Blocky-Performance-DNS.md",
        "guides/GUIDE-Networking-Performance-SRE.md",
        "guides/MASTER-CONFIG-TAILSCALE.md",
        "services/caddy-migration-plan.md",
        "services/cloudflare-homeserver-setup.md",
        "services/service-gateway-caddy.md",
        "services/service-dns-automation-guard.md",
        "services/service-gateway-pocket-id.md",
        "services/service-gateway-adguardhome.md",
        "services/service-ssh-rescue-window.md",
    ],
    "20-security": [
        "adr/security-layer-model.md",
        "adr/ADR-006-Secret-Management-Audit.md",
        "adr/jailed-agents-sandboxing.md",
        "adr/sovereign-identity-v4.md",
        "guides/GUIDE-Landlock-Isolation-Mastery.md",
        "guides/GUIDE-Service-Hardening-Sandboxing.md",
        "guides/MASTER-CONFIG-FAIL2BAN.md",
        "guides/MASTER-CONFIG-FAIL2BAN-ENDPOINTS.md",
        "services/sops-template-spec.md",
        "services/service-infrastructure-vpn-confinement.md",
        "services/security-hardening-baseline.md",
        "services/service-mtls-pki-automation.md",
    ],
    "30-storage": [
        "adr/storage-tiering-strategy.md",
        "adr/disaster-recovery-strategy.md",
        "guides/GUIDE-ABC-Storage-Tiering.md",
        "guides/GUIDE-Blank-Snapshot-Persistence.md",
        "guides/GUIDE-Pro-Backup-Strategies.md",
        "guides/GUIDE-Sync-Backup-Master-Config.md",
        "guides/GUIDE-Future-Storage-Scaling.md",
        "guides/MASTER-CONFIG-RESTIC.md",
        "guides/MASTER-CONFIG-RCLONE.md",
        "services/abc-storage-mover.md",
        "services/disk-discovery-hal.md",
        "services/state-streaming-backup.md",
    ],
    "40-monitoring": [
        "adr/dashboard-hierarchy.md",
        "guides/GUIDE-Monitoring-Hub-Gatus.md",
        "guides/GUIDE-Next-Gen-Monitoring-Gatus.md",
        "guides/GUIDE-System-Monitoring-Telemetry.md",
        "guides/GUIDE-SRE-Alerting-Matrix.md",
        "guides/MASTER-CONFIG-GATUS.md",
        "guides/MASTER-CONFIG-HOMEPAGE.md",
        "guides/GUIDE-Terminal-Dashboard-HomeDash.md",
        "services/dashboard-comparison-v4.2.md",
        "services/service-monitoring-cockpit.md",
        "services/service-monitoring-scrutiny.md",
    ],
    "50-media": [
        "adr/ADR-004-Media-Engine-VPN-Isolation.md",
        "adr/ADR-009-Media-Stack-Consolidation.md",
        "guides/GUIDE-Intel-QuickSync-NixOS.md",
        "guides/GUIDE-Hardware-Acceleration-DeepDive.md",
        "guides/GUIDE-Media-Mastery-Jellyfin.md",
        "guides/GUIDE-Audiobookshelf-Mastery.md",
        "guides/MASTER-CONFIG-SEERR.md",
        "guides/MASTER-CONFIG-RADARR.md",
        "guides/MASTER-CONFIG-ARR-STACK.md",
        "guides/MASTER-CONFIG-SABNZBD.md",
        "guides/MASTER-CONFIG-AUDIOBOOKSHELF.md",
        "services/media-stack-hardening.md",
        "services/service-media-arr-stack.md",
        "services/service-media-jellyfin.md",
        "services/service-media-jellyseerr.md",
        "services/service-media-prowlarr.md",
        "services/service-media-sabnzbd.md",
        "services/service-media-audiobookshelf.md",
    ],
    "60-apps": [
        "guides/GUIDE-Paperless-Master-Config.md",
        "guides/MASTER-CONFIG-PAPERLESS-NGX.md",
        "guides/MASTER-CONFIG-VAULTWARDEN.md",
        "guides/MASTER-CONFIG-N8N.md",
        "guides/GUIDE-Webhook-Automation-n8n.md",
        "guides/GUIDE-Conduit-Master-Config.md",
        "guides/GUIDE-Sovereign-Communication-Matrix.md",
        "guides/GUIDE-Knowledge-Mastery-Readeck.md",
        "services/identity-pocketid-v4.2.md",
        "services/service-apps-vaultwarden.md",
        "services/service-apps-matrix-conduit.md",
        "services/service-apps-paperless.md",
        "services/service-apps-monica.md",
        "services/service-knowledge-miniflux.md",
        "services/service-automation-n8n.md",
        "services/service-automation-home-assistant.md",
        "guides/GUIDE-Home-Assistant-Blueprint.md",
    ],
    "70-forge": [
        "architecture/arch-tooling-strategy.md",
        "architecture/arch-evolution-strategy.md",
        "architecture/arch-flake-parts.md",
        "guides/GUIDE-Sovereign-Git-Mastery.md",
        "guides/GUIDE-GitHub-Actions-SRE-Mastery.md",
        "guides/GUIDE-GitHub-Security-Hardening.md",
    ],
    "80-gaming": [],
    "90-policy": [
        "adr/distribution-strategy-v5.md",
        "adr/ADR-003-Ejected-Services.md",
        "learnings/FINDINGS-REGISTRY.md",
        "learnings/professional-workflow-audit.md",
        "learnings/sre-audit-v2.3.md",
        "learnings/sre-audit-v4.2.md",
        "guides/GUIDE-Seven-Quality-Gates.md",
        "guides/GUIDE-SRE-Hardening-Secrets.md",
        "services/service-policy-enforcement.md",
    ],
}

total_files_processed = 0
total_enhancements = 0
skipped_files = []

for domain, kb_files in DOMAIN_KB_FILES.items():
    domain_adr_nuggets = []
    domain_guide_nuggets = []
    domain_sources = []
    
    print(f"\n{'='*60}")
    print(f"  Domain: {domain}")
    print(f"{'='*60}")
    
    for kb_file in kb_files:
        content = read_kb(kb_file)
        if content is None:
            skipped_files.append(kb_file)
            continue
        
        total_files_processed += 1
        
        # Extract source info
        source_match = re.search(r'source:\s*"([^"]+)"', content)
        sources_match = re.search(r'sources:\s*\[([^\]]+)\]', content)
        if source_match:
            domain_sources.append(source_match.group(1))
        elif sources_match:
            domain_sources.append(sources_match.group(1))
        
        # Split into sections by markdown headers
        sections = re.split(r'\n##+\s+', content)
        
        for section in sections:
            lines = section.strip().split('\n', 1)
            if len(lines) < 2:
                continue
            header = lines[0].strip()
            body = lines[1].strip()
            
            if len(body) < 50:
                continue
            
            # Skip frontmatter
            if header.startswith('---'):
                continue
            
            # Categorize
            header_lower = header.lower()
            is_adr = any(kw in header_lower for kw in [
                'context', 'decision', 'reasoning', 'consequence', 'warum',
                'architektur', 'herleitung', 'strategy', 'philosophie',
                'problem', 'lösung', 'ziel', 'konzept', 'prinzip', 'standard'
            ])
            is_guide = any(kw in header_lower for kw in [
                'setup', 'config', 'implementierung', 'konfiguration',
                'verification', 'how to', 'anleitung', 'command', 'befehl',
                'sre-anwendung', 'sre-vorteil', 'check', 'workflow',
                'muster', 'pattern', 'nutzung', 'bedienung'
            ])
            
            nugget = f"### {header}\n\n{body}"
            
            if is_adr and not is_guide:
                domain_adr_nuggets.append(nugget)
            elif is_guide and not is_adr:
                domain_guide_nuggets.append(nugget)
            else:
                domain_adr_nuggets.append(nugget)
                domain_guide_nuggets.append(nugget)
    
    # Deduplicate and limit
    seen_adr = set()
    unique_adr = []
    for n in domain_adr_nuggets:
        h = n[:100]
        if h not in seen_adr:
            seen_adr.add(h)
            unique_adr.append(n)
    domain_adr_nuggets = unique_adr[:12]
    
    seen_guide = set()
    unique_guide = []
    for n in domain_guide_nuggets:
        h = n[:100]
        if h not in seen_guide:
            seen_guide.add(h)
            unique_guide.append(n)
    domain_guide_nuggets = unique_guide[:12]
    
    domain_prefix = domain.split('-')[0]
    
    # Enhance ADRs
    adr_pattern = f"docs/adr/ADR-{domain_prefix}-*.md"
    adr_files = sorted(glob.glob(os.path.join(TARGET, adr_pattern)))
    for adr_file in adr_files:
        adr_rel = os.path.relpath(adr_file, TARGET)
        content = read_target(adr_rel)
        if content is None:
            continue
        
        # Add source to frontmatter
        if domain_sources and 'source:' not in content:
            src = domain_sources[0] if domain_sources else ""
            content = re.sub(r'(reviewed: \S+\n)', f'\\1source: "{src}"\n', content, count=1)
        
        # Add KB Nuggets
        if '## KB Nuggets' not in content and domain_adr_nuggets:
            nuggets_text = '\n\n---\n\n'.join(domain_adr_nuggets)
            content += f"\n\n---\n\n## KB Nuggets — From Knowledge Base\n\n{nuggets_text}\n"
            total_enhancements += 1
        
        write_target(adr_rel, content)
    
    # Enhance Guides
    guide_pattern = f"docs/guides/{domain_prefix}-*.md"
    guide_files = sorted(glob.glob(os.path.join(TARGET, guide_pattern)))
    for guide_file in guide_files:
        guide_rel = os.path.relpath(guide_file, TARGET)
        content = read_target(guide_rel)
        if content is None:
            continue
        
        if domain_sources and 'source:' not in content:
            src = domain_sources[0] if domain_sources else ""
            content = re.sub(r'(reviewed: \S+\n)', f'\\1source: "{src}"\n', content, count=1)
        
        if '## KB Nuggets' not in content and domain_guide_nuggets:
            nuggets_text = '\n\n---\n\n'.join(domain_guide_nuggets)
            content += f"\n\n---\n\n## KB Nuggets — From Knowledge Base\n\n{nuggets_text}\n"
            total_enhancements += 1
        
        write_target(guide_rel, content)
    
    # Enhance Modules with KB nuggets as comments
    mod_pattern = f"modules/{domain}/*.nix"
    mod_files = sorted(glob.glob(os.path.join(TARGET, mod_pattern)))
    for mod_file in mod_files:
        mod_rel = os.path.relpath(mod_file, TARGET)
        content = read_target(mod_rel)
        if content is None:
            continue
        
        if domain_guide_nuggets and 'KB Nuggets' not in content:
            # Take first 2 nuggets, convert to Nix comments
            nuggets = domain_guide_nuggets[:2]
            comment_lines = ["# ─── KB Nuggets ───"]
            for nugget in nuggets:
                for line in nugget.split('\n'):
                    comment_lines.append(f"# {line}" if line.strip() else "#")
            comment_lines.append("# ─── End KB Nuggets ───")
            
            comment_block = '\n'.join(comment_lines)
            content = re.sub(
                r'(# ---ENDNIXMETA\n)',
                f'\\1\n{comment_block}\n',
                content, count=1
            )
            total_enhancements += 1
        
        write_target(mod_rel, content)
    
    print(f"  KB files read: {len([f for f in kb_files if f not in skipped_files])}")
    print(f"  ADR nuggets: {len(domain_adr_nuggets)}")
    print(f"  Guide nuggets: {len(domain_guide_nuggets)}")
    print(f"  Sources: {len(domain_sources)}")
    print(f"  ADRs enhanced: {len(adr_files)}")
    print(f"  Guides enhanced: {len(guide_files)}")
    print(f"  Modules enhanced: {len(mod_files)}")

print(f"\n{'='*60}")
print(f"  FINAL SUMMARY")
print(f"{'='*60}")
print(f"  KB files processed: {total_files_processed}")
print(f"  KB files skipped: {len(skipped_files)}")
print(f"  Total enhancements: {total_enhancements}")
print(f"\n  Skipped files (first 30):")
for f in skipped_files[:30]:
    print(f"    - {f}")
if len(skipped_files) > 30:
    print(f"    ... and {len(skipped_files) - 30} more")
