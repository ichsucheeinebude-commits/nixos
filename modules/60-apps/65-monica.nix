# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-006"
# title: "Monica CRM"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [monica,crm,personal,relationships,php]
# description: "Personal CRM for managing relationships with strict sandboxing."
# path: "modules/60-apps/65-monica.nix"
# provides: [my.apps.monica]
# requires: [10-network, 20-security]
# links:
#   module: modules/60-apps/65-monica.nix
# source: _meta/60-apps/service-app-monica.nix (NIXH-60-APP-006)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  cfg = config.my.apps.monica;
  port = config.my.ports.monica or 20004;
  domain = config.my.configs.identity.domain or "m7c5.de";
  appKeyFile = "/var/lib/monica/app-key";
in
{
  options.my.apps.monica = {
    enable = lib.mkEnableOption "Monica personal CRM";
  };

  config = lib.mkIf cfg.enable {
    services.monica = {
      enable = true;
      hostname = "monica.${domain}";
      appURL = "https://monica.${domain}";
      inherit appKeyFile;
      nginx.listen = [ { addr = "127.0.0.1"; port = port; ssl = false; } ];
      database.createLocally = true;
    };

    services.caddy.virtualHosts."monica.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString port}";
    };

    # Generate app key if not exists
    system.activationScripts.monicaAppKeyFile.text = ''
      install -d -m 0750 -o monica -g monica /var/lib/monica
      if [ ! -s ${appKeyFile} ]; then
        head -c 32 /dev/urandom | base64 > ${appKeyFile}
      fi
    '';

    systemd.services.phpfpm-monica.serviceConfig = {
      ProtectSystem = lib.mkForce "strict";
      ProtectHome = true;
      PrivateTmp = true;
      PrivateDevices = true;
      ReadWritePaths = [ "/var/lib/monica" ];
    };
  };
}
