# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-004"
# title: "Secrets Schema"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [security,sops,schema]
# description: "Declarative schema for SOPS secret definitions."
# path: "modules/20-security/23-secrets-schema.nix"
# provides: [my.security.secretsSchema]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/20-security/23-secrets-schema.nix
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
  options.my.security.secretsSchema = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    schema = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
    };
  };

  config = lib.mkIf config.my.security.secretsSchema.enable {
    assertions = lib.mapAttrsToList (name: def: {
      assertion = config.sops.secrets ? ${name} || def.optional or false;
      message = "Missing required secret: ${name}";
    }) config.my.security.secretsSchema.schema;
  };
}
