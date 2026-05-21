# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-005"
# title: "Readeck"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,readeck,reader]
# description: "Readeck read-it-later service."
# path: "modules/60-apps/64-readeck.nix"
# provides: [my.apps.readeck]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/60-apps/64-readeck.nix
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
  options.my.apps.readeck = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8000; };
  };

  config = lib.mkIf config.my.apps.readeck.enable {
    services.readeck = {
      enable = true;
      settings = {
        server.host = "127.0.0.1";
        server.port = config.my.apps.readeck.port;
      };
    };
  };
}
