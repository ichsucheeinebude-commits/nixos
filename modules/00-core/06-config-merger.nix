# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-007"
# title: "Config Merger"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [config,merger,json,runtime,overrides]
# description: "Dynamic bridge between NixOS declarations and user-managed JSON overrides for runtime services."
# path: "modules/00-core/06-config-merger.nix"
# provides: [my.configMerger]
# requires: [00-core]
# links:
#   module: modules/00-core/06-config-merger.nix
# source: _meta/00-core/config-merger.nix (NIXH-00-COR-007)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  runDir = "/run/nixhome";
  userConfig = "/var/lib/nixhome/user-config.json";
  finalConfig = "${runDir}/config.json";

  nixDefaults = pkgs.writeText "nix-defaults.json" (builtins.toJSON {
    domain = config.my.configs.identity.domain;
    email = config.my.configs.identity.email;
    lanIP = config.my.configs.server.lanIP;
    hostName = config.my.configs.identity.host;
    bastelmodus = config.my.configs.bastelmodus;
  });

  mergerScript = pkgs.writeShellScript "nixhome-config-merger" ''
    set -euo pipefail
    mkdir -p ${runDir}
    if [ ! -f "${userConfig}" ]; then
      echo "{}" > "${userConfig}"
      chown root:root "${userConfig}"
      chmod 644 "${userConfig}"
    fi
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${nixDefaults}" "${userConfig}" > "${finalConfig}.tmp"
    mv "${finalConfig}.tmp" "${finalConfig}"
    chmod 644 "${finalConfig}"
  '';
in
{
  options.my.configMerger.enable = lib.mkEnableOption "Config merger service";

  config = lib.mkIf config.my.configMerger.enable {
    systemd.services.nixhome-config-merger = {
      description = "Merge Nix Defaults with User JSON Config";
      before = [ "caddy.service" "pocket-id.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = mergerScript;
      };
    };

    environment.systemPackages = [ pkgs.jq ];
    systemd.tmpfiles.rules = [ "d /var/lib/nixhome 0755 root root -" ];
  };
}
