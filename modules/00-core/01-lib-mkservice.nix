# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-001"
# title: "MkService Helper Library"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [library,helper,mkservice,caddy,sso,sandboxing]
# description: "Reusable service factory: generates systemd sandboxing, Caddy vhosts with SSO, and network namespace support."
# path: "modules/00-core/01-lib-mkservice.nix"
# provides: [my.lib.mkService]
# requires: []
# links:
#   module: modules/00-core/01-lib-mkservice.nix
# source: _meta/00-core/lib-helpers.nix (NIXH-00-COR-001)
# ---
# ---ENDNIXMETA
{ lib, config, ... }:
let
  domain = config.my.configs.identity.domain;
  baseDomain = "nix.${domain}";
in
{
  options.my.lib.mkService = lib.mkOption {
    type = lib.types.functionTo lib.types.attrs;
    internal = true;
    description = "Reusable service factory function.";
  };

  config.my.lib = {
    mkService = { name
                 , port
                 , useSSO ? true
                 , description ? "Managed Service"
                 , readWritePaths ? []
                 , allowNetwork ? true
                 , netns ? null
                 , targetHost ? "127.0.0.1"
                 }:
      let
        host = "${name}.${baseDomain}";
        target = "http://${if netns != null then "10.200.1.2" else targetHost}:${toString port}";
        trustedIPs = "127.0.0.1 100.64.0.0/10";
      in {
        systemd.services."${name}".serviceConfig = {
          Description = lib.mkDefault description;
          ProtectSystem = lib.mkDefault "strict";
          ProtectHome = lib.mkDefault true;
          PrivateTmp = lib.mkDefault true;
          PrivateDevices = lib.mkDefault true;
          NoNewPrivileges = lib.mkDefault true;
          Restart = lib.mkDefault "always";
          ReadWritePaths = lib.mkDefault readWritePaths;
          NetworkNamespacePath = lib.mkIf (netns != null) "/run/netns/${netns}";
          CapabilityBoundingSet = lib.mkIf (!allowNetwork) [];
        };

        services.caddy.virtualHosts."${host}" = {
          extraConfig = ''
            @trusted_network remote_ip ${trustedIPs}
            handle @trusted_network {
              reverse_proxy ${target}
            }
            ${lib.optionalString useSSO "import sso_auth"}
            reverse_proxy ${target}
          '';
        };
      };
  };
}
