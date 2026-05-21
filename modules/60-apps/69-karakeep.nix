# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-010"
# title: "Karakeep"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,karakeep,bookmarks]
# description: "Karakeep bookmark management."
# path: "modules/60-apps/69-karakeep.nix"
# provides: [my.apps.karakeep]
# requires: []
# links:
#   adr: docs/adr/ADR-60-apps.md
#   guide: docs/guides/60-apps.md
#   module: modules/60-apps/69-karakeep.nix
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
# - Der Dienst wird via Caddy (Layer 20) über \`paperless.m7c5.de\` mit mTLS abgesichert.
# - Der Konsum-Ordner (\`consumptionDir\`) wird für den Scanner im Netzwerk freigegeben.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.apps.karakeep = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 3012; };
    disableSignups = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.apps.karakeep.enable {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString config.my.apps.karakeep.port;
        DISABLE_SIGNUPS = if config.my.apps.karakeep.disableSignups then "true" else "false";
      };
    };
  };
}
