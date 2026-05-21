# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-025"
# title: "Port Registry"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [ports,registry,ssot,networking]
# description: "Central port registry with 10k/20k schema mapping and duplicate detection."
# path: "modules/00-core/03-ports.nix"
# provides: [my.ports]
# requires: []
# links:
#   module: modules/00-core/03-ports.nix
# source: _meta/00-core/ports.nix (NIXH-00-COR-025)
# ---
# ---ENDNIXMETA
{ lib, config, ... }:
let
  allPorts = lib.attrValues config.my.ports;
  hasDuplicates = (lib.length (lib.unique allPorts)) != (lib.length allPorts);
in
{
  options.my.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = {};
    description = "Central port registry.";
  };

  config.my.ports = {
    # ── System & Edge ──
    ssh = 53844;
    edgeHttps = 443;

    # ── 10-Infrastructure ──
    adguard = 10000;
    uptimeKuma = 10001;
    pocketId = 10010;
    homepage = 10082;
    netdata = 10999;
    valkey = 6379;
    olivetin = 10080;
    cockpit = 10090;
    ddnsUpdater = 10100;

    # ── 20-Apps / Media ──
    jellyfin = 20096;
    vaultwarden = 20002;
    n8n = 20017;
    paperless = 20981;
    ollama = 11434;
    sonarr = 20989;
    radarr = 20878;
    lidarr = 20686;
    prowlarr = 20696;
    readarr = 20787;
    sabnzbd = 20080;
    jellyseerr = 25055;
    matrix = 20006;
    audiobookshelf = 20081;
    readeck = 20005;
    scrutiny = 20007;
    miniflux = 20008;
    filebrowser = 20001;
    karakeep = 20003;
    openWebui = 20009;
    monica = 20004;
    linkwarden = 3000;

    # ── IoT & Messaging ──
    zigbee2mqtt = 28080;
    mqtt = 1883;

    # ── Monitoring ──
    gatus = 8080;
    homeAssistant = 8123;
  };

  # SRE Safety: Warn on port collision
  warnings = lib.optional hasDuplicates "⚠️ [SRE-WARNING] Duplicate port assignment in registry!";
}
