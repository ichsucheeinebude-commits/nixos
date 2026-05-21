# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-MON-001"
# title: "Gatus Health Dashboard"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [monitoring,gatus,health]
# description: "Gatus health monitoring with configurable endpoints."
# path: "modules/40-monitoring/40-gatus.nix"
# provides: [my.monitoring.gatus]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/40-monitoring/40-gatus.nix
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

{ config, lib, pkgs, ... }:
{
  options.my.monitoring.gatus = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 8081; };
    ntfyUrl = lib.mkOption { type = lib.types.str; default = ""; };
    ntfyTopic = lib.mkOption { type = lib.types.str; default = "gatus-alerts"; };
    endpoints = lib.mkOption { type = lib.types.listOf lib.types.attrs; default = []; };
  };

  config = lib.mkIf config.my.monitoring.gatus.enable {
    services.gatus = {
      enable = true;
      settings = {
        web = { address = "127.0.0.1"; port = config.my.monitoring.gatus.port; };
        storage = { type = "sqlite"; path = "/var/lib/gatus/data.db"; };
        endpoints = config.my.monitoring.gatus.endpoints;
      };
    };
  };
}
