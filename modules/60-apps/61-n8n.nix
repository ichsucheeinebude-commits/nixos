# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-002"
# title: "n8n Automation"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,n8n,workflows]
# description: "n8n workflow automation platform."
# path: "modules/60-apps/61-n8n.nix"
# provides: [my.apps.n8n]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/61-n8n.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### ⚙️ Deklarative Nix-Konfiguration
#
# Hier ist das Muster für deinen Dendriten (\`modules/50-knowledge/paperless.nix\`):
#
# \`\`\`nix
# services.paperless = {
#   enable = true;
#   address = "0.0.0.0";
#   port = 28981;
#   settings = {
#     # Hier kommen alle App-Variablen rein!
#     PAPERLESS_TIME_ZONE = "Europe/Berlin";
#     PAPERLESS_OCR_LANGUAGE = "deu+eng";
#     PAPERLESS_OCR_MODE = "clean";
#     PAPERLESS_AUTO_LOGIN_USERNAME = "admin"; # Nur lokal sicher!
#     PAPERLESS_FILENAME_FORMAT = "{{created_year}}/{{correspondent}}/{{title}}";
#   };
#   # Secrets (API-Keys etc.) kommen hier rein:
#   environmentFile = config.sops.secrets."paperless/env".path;
# };
# \`\`\`
# ### 🛡️ SRE-Hardening
#
# - Der Dienst wird via Caddy (Layer 20) über \`paperless.<DOMAIN>\` mit mTLS abgesichert.
# - Der Konsum-Ordner (\`consumptionDir\`) wird für den Scanner im Netzwerk freigegeben.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.apps.n8n = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 5678; };
    databaseType = lib.mkOption { type = lib.types.enum [ "sqlite" "postgres" ]; default = "postgres"; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "2G"; };
  };
}
