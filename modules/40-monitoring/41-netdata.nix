# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-002"
# title: "Netdata Telemetry"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,netdata,metrics]
# description: "Netdata real-time performance monitoring."
# path: "modules/40-monitoring/41-netdata.nix"
# provides: [my.monitoring.netdata]
# requires: []
# links:
#   adr: docs/adr/ADR-41-netdata.md
#   guide: docs/guides/41-netdata.md
#   module: modules/40-monitoring/41-netdata.nix
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
  options.my.monitoring.netdata = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 19999; };
  };

  config = lib.mkIf config.my.monitoring.netdata.enable {
    services.netdata = {
      enable = true;
      config = {
        global = { "memory mode" = "dbengine"; };
        web = { "bind to" = "unix:/run/netdata/netdata.sock"; };
      };
    };
  };
}
