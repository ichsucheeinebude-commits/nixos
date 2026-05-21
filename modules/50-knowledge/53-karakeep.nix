# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-60-APP-004"
# title: "Karakeep (SRE Hardened)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [karakeep,bookmarks,web-app,sandboxing]
# description: "Bookmark management tool with SRE sandboxing."
# path: "modules/50-knowledge/53-karakeep.nix"
# provides: [my.knowledge.karakeep]
# requires: [10-network]
# links:
#   module: modules/50-knowledge/53-karakeep.nix
# source: _meta/60-apps/service-app-karakeep.nix (NIXH-60-APP-004)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.knowledge.karakeep;
  port = config.my.ports.karakeep or 20003;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.knowledge.karakeep = {
    enable = lib.mkEnableOption "Karakeep bookmark manager";
    disableSignups = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString port;
        DISABLE_SIGNUPS = if cfg.disableSignups then "true" else "false";
      };
    };

    services.caddy.virtualHosts."bookmarks.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };
  };
}
