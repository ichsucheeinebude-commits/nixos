# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-004"
# title: "Scrutiny SMART"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,scrutiny,smart]
# description: "Hard drive S.M.A.R.T. monitoring with Scrutiny."
# path: "modules/40-monitoring/43-scrutiny.nix"
# provides: [my.monitoring.scrutiny]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/43-scrutiny.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: WER SIEHT WAS? (KISS)
#
# - **Admin (Du):** Braucht volle Kontrolle, RSS-Feeds, Server-Stats und Arrr-Queues.
# - **Familie:** Braucht nur drei Knöpfe: Filme, Serien, Hörbücher. Alles andere würde nur verwirren.
#
# ---
# ### A. Admin Dashboard: Glance
#
# - **Warum:** Einzelne Go-Binary, extrem leichtgewichtig (<20MB RAM).
# - **Features:** Widgets für Sonarr/Radarr, RSS-Feeds, Wetter, Server-Stats.
# - **NixOS-Integration:** Reine YAML-Konfiguration, perfekt deklarativ.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.monitoring.scrutiny = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8082; };
  };

  config = lib.mkIf config.my.monitoring.scrutiny.enable {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = config.my.monitoring.scrutiny.port;
        web.listen.host = "127.0.0.1";
      };
      collector.enable = true;
    };
    services.smartd.enable = true;
  };
}
