# ---NIXMETA
# ---
# domain: 40
# id: "NIXH-40-NTF-001"
# title: "Ntfy Notifications"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [ntfy, notifications]
# description: "Ntfy Notifications module."
# path: "modules/40-monitoring/42-ntfy.nix"
# provides: [my.monitoring.ntfy]
# requires: [40-monitoring/41-netdata]
# links:
#   adr: docs/adr/ADR-40-ntfy.md
#   guide: docs/guides/40-ntfy.md
#   module: modules/40-monitoring/42-ntfy.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, myLib, ... }:

let
  cfg = config.my.services.ntfy;
in {
  options.my.services.ntfy = {
    enable = lib.mkEnableOption "ntfy-sh Local Server";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (myLib.mkService {
      inherit config;
      name = "ntfy";
      port = config.my.ports.ntfy;
      useSSO = true; # Authentication via Pocket-ID/family_auth
      description = "ntfy-sh Local Server";
      persist = true;
    })
    {
      services.ntfy-sh = {
        enable = true;
        settings = {
          base-url = "https://ntfy.${config.my.configs.identity.subdomain}.${config.my.configs.identity.domain}";
          listen-http = "127.0.0.1:${toString config.my.ports.ntfy}";
          behind-proxy = true;
          # Access control can be added here if needed, but Caddy handles SSO
        };
      };
    }
  ]);
}
