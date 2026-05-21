# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-013"
# title: "Landing Zone UI"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,web,landing-page,static,dashboard]
# description: "Static landing page served via Caddy with rescue fallback."
# path: "modules/10-network/23-landing-zone-ui.nix"
# provides: [my.network.landingZone]
# requires: [my.network.caddy]
# links:
#   adr: docs/adr/ADR-23-landing-zone-ui.md
#   guide: docs/guides/23-landing-zone-ui.md
#   module: modules/10-network/23-landing-zone-ui.nix
#   upstream: https://caddyserver.com/docs/caddyfile/directives/root
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Ein Homelab braucht eine zentrale Anlaufstelle — eine Landing Page, die
# alle verfügbaren Dienste auflistet und im Notfall einen Rettungsweg zeigt.
#
# ### Entscheidung
#
# **Landing Zone Pattern:**
# 1.  **Static HTML** — Minimale Index-Seite als Einstiegspunkt.
# 2.  **Caddy Root** — Wird vom Caddy-Proxy an der Hauptdomain serviert.
# 3.  **Rescue Fallback** — Zeigt "Rettungsweg" wenn alles andere ausfällt.
# 4.  **tmpfiles** — Verzeichnis-Management über systemd-tmpfiles.
#
# ### SRE-Standards
#
# - Verzeichnis: /var/www/landing-zone (0755, caddy:caddy).
# - Index wird per Symlink aus Nix-Store generiert (deklarativ).
# - mTLS-Zertifikate werden im selben Verzeichnis abgelegt.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

{
  options.my.network.landingZone = {
    enable = lib.mkEnableOption "Static landing page with rescue fallback";
    htmlContent = lib.mkOption {
      type = lib.types.str;
      default = ''
        <!DOCTYPE html>
        <html lang="en">
        <head><meta charset="utf-8"><title>HomeLab</title>
        <style>body{font-family:system-ui;max-width:600px;margin:40px auto;padding:20px;background:#1a1a2e;color:#eee}</style>
        </head>
        <body><h1>🛰️ HomeLab</h1><p>Service dashboard coming soon.</p></body>
        </html>
      '';
      description = "HTML content for the landing page.";
    };
  };

  config = lib.mkIf config.my.network.landingZone.enable {
    # ── Static HTML from Nix Store ──
    environment.etc."landing-zone/index.html" = {
      source = pkgs.writeText "landing-index.html" config.my.network.landingZone.htmlContent;
    };

    # ── Landing Zone Directory ──
    systemd.tmpfiles.rules = [
      "d /var/www/landing-zone 0755 caddy caddy -"
      "L+ /var/www/landing-zone/index.html - - - - /etc/landing-zone/index.html"
      "d /var/www/landing-zone/certs 0755 caddy caddy -"
    ];
  };
}
