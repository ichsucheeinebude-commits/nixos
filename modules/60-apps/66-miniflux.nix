# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-007"
# title: "Miniflux RSS"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [apps,miniflux,rss]
# description: "Miniflux RSS reader."
# path: "modules/60-apps/66-miniflux.nix"
# provides: [my.apps.miniflux]
# requires: []
# links:
#   adr: docs/adr/ADR-60-apps.md
#   guide: docs/guides/60-apps.md
#   module: modules/60-apps/66-miniflux.nix
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
  options.my.apps.miniflux = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8085; };
  };

  config = lib.mkIf config.my.apps.miniflux.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString config.my.apps.miniflux.port}";
        RUN_MIGRATIONS = 1;
      };
    };
  };
}
