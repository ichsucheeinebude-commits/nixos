# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-090-MON-NTFY-001",
#   "title": "ntfy-sh Local Server",
#   "layer": 90,
#   "category": "services/monitoring",
#   "lastReviewed": "2026-05-15",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["monitoring", "ntfy", "alerting"],
#   "description": "Local ntfy-sh server for internal alerts, replacing public instances."
# }
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
