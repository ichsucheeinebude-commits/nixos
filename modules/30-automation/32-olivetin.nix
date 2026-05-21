# ---NIXMETA
# ---
# domain: 30
# id: "NIXH-30-AUT-005"
# title: "OliveTin (Web Shell)"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [olivetin,web-shell,automation,runbook]
# description: "Web shell for safe command execution with predefined actions."
# path: "modules/30-automation/32-olivetin.nix"
# provides: [my.automation.olivetin]
# requires: [10-network]
# links:
#   module: modules/30-automation/32-olivetin.nix
# source: _meta/30-automation/service-app-olivetin.nix (NIXH-30-AUT-005)
# ---
# ---ENDNIXMETA
{ config, lib, ... }:
let
  cfg = config.my.automation.olivetin;
  port = config.my.ports.olivetin or 10080;
  domain = config.my.configs.identity.domain or "m7c5.de";
in
{
  options.my.automation.olivetin = {
    enable = lib.mkEnableOption "OliveTin web shell";
    configPath = lib.mkOption {
      type = lib.types.str;
      default = "/etc/nixos/olivetin-config.yaml";
      description = "Path to OliveTin config file.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.olivetin = {
      enable = true;
      port = port;
      inherit (cfg) configPath;
    };

    services.caddy.virtualHosts."shell.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    systemd.services.olivetin.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      PrivateTmp = true;
      NoNewPrivileges = true;
      OOMScoreAdjust = 200;
    };
  };
}
