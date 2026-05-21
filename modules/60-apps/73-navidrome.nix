# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-073"
# title: "Navidrome Music Server"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [apps,music,navidrome,subsonic,streaming]
# description: "Hardened Navidrome music streaming server with Subsonic API enabled. ABC-tiering for state/cache/music directories."
# path: "modules/60-apps/73-navidrome.nix"
# provides: [my.media.navidrome]
# requires: [00-core]
# links:
#   module: modules/60-apps/73-navidrome.nix
# source: mynixos-v5/modules/apps/service-app-navidrome.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.media.navidrome;
  stateDir = config.my.core.paths.stateDir or "/data/state";
  tierB = config.my.core.paths.tierB or "/mnt/fast-pool";
  mediaLibrary = config.my.core.paths.mediaLibrary or "/mnt/media";
  domain = config.my.core.identity.domain or "example.com";
  subdomain = config.my.core.identity.subdomain or "nix";
in
{
  # ── Navidrome Music Server ──
  # Hardened music streaming with Subsonic API.

  options.my.media.navidrome = {
    enable = lib.mkEnableOption "Navidrome music streaming server";
    user = lib.mkOption {
      type = lib.types.str;
      default = "navidrome";
    };
    group = lib.mkOption {
      type = lib.types.str;
      default = "media";
    };
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.navidrome or 4533;
      description = "Navidrome web UI port.";
    };
    stateDir = lib.mkOption {
      type = lib.types.str;
      default = "${stateDir}/navidrome";
      description = "Database and config directory (persistent).";
    };
    cacheDir = lib.mkOption {
      type = lib.types.str;
      default = "${tierB}/cache/navidrome";
      description = "Cache directory (Tier B, fast storage).";
    };
    musicDir = lib.mkOption {
      type = lib.types.str;
      default = "${mediaLibrary}/music";
      description = "Music library directory.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── System User ──
    users.users.${cfg.user} = {
      isSystemUser = true;
      group = cfg.group;
      home = cfg.stateDir;
      extraGroups = [ "media" ];
    };

    # ── Navidrome Service ──
    services.navidrome = {
      enable = true;
      user = cfg.user;
      group = cfg.group;
      address = "127.0.0.1";
      port = cfg.port;
      musicFolder = cfg.musicDir;
      dataFolder = cfg.stateDir;
      cacheFolder = cfg.cacheDir;
      settings.EnableSubsonicApi = true;
    };

    # ── Caddy Virtual Host ──
    services.caddy.virtualHosts."music.${subdomain}.${domain}" =
      config.services.caddy.virtualHosts."navidrome.${subdomain}.${domain}";

    # ── Security ──
    systemd.services.navidrome.serviceConfig.ReadOnlyPaths = [ cfg.musicDir ];

    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 ${cfg.user} ${cfg.group} -"
      "d ${cfg.cacheDir} 0750 ${cfg.user} ${cfg.group} -"
    ];
  };
}
