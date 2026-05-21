# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-003"
# title: "Secrets Management"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [security,sops,secrets]
# description: "SOPS-based secrets management."
# path: "modules/20-security/22-secrets.nix"
# provides: [my.security.secrets]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/20-security/22-secrets.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: DIE TÜRSTEHER-LOGIK (KISS)
#
# Wir schützen den Server wie eine exklusive Veranstaltung:
# 1. **Der Zaun (Schicht 1):** Cloudflare blockt böse Länder und Bots.
# 2. **Der Ausweis-Check (Schicht 2):** Wer rein will, braucht einen digitalen Passkey (OIDC).
# 3. **Der VIP-Schlüssel (Schicht 3):** Für die Technik-Räume (Admin) reicht ein Passkey nicht aus – hier muss das Gerät selbst ein Zertifikat haben.
#
# ---
# ### Schicht 1: Cloudflare Edge (WAF)
#
# - **Modus:** Orange Cloud (Proxied).
# - **Features:** WAF (Free Plan), Bot Fight Mode, Strict SSL/TLS (Full End-to-End).
# - **Geoblocking:** Sperrung aller Regionen außer DACH (DE/AT/CH).
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.security.secrets = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    ageKeyFile = lib.mkOption { type = lib.types.str; default = "/etc/sops-nix/age-keys.txt"; };
    defaultSopsFile = lib.mkOption { type = lib.types.path; default = null; };
  };

  config = lib.mkIf config.my.security.secrets.enable {
    sops = {
      defaultSopsFile = lib.mkIf (config.my.security.secrets.defaultSopsFile != null) config.my.security.secrets.defaultSopsFile;
      age.keyFile = lib.mkIf (config.my.security.secrets.ageKeyFile != "") config.my.security.secrets.ageKeyFile;
      secrets = {};
    };
  };
}
