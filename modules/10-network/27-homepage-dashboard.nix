# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-027"
# title: "Homepage Dashboard"
# description: "Declarative application dashboard with service discovery widgets."
# tags: ["dashboard", "homepage", "ui"]
# nixmeta: "https://github.com/gethomepage/homepage"
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.homepage-dashboard;
in
{
  options.my.services.homepage-dashboard = {
    enable = lib.mkEnableOption "Homepage application dashboard";

    port = lib.mkOption {
      type = lib.types.port;
      default = 3000;
      description = "Port for homepage-dashboard.";
    };

    title = lib.mkOption {
      type = lib.types.str;
      default = "Homelab Dashboard";
      description = "Dashboard title.";
    };

    host = lib.mkOption {
      type = lib.types.str;
      default = "dash";
      description = "Caddy virtual host subdomain.";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.homepage-dashboard ];

    services.homepage-dashboard = {
      enable = true;

      widgets = [
        { resources = { cpu = true; memory = true; disk = "/"; uptime = true; }; }
        { search = { provider = "duckduckgo"; target = "_blank"; }; }
      ];

      settings = {
        title = cfg.title;
        layout = {
          Media = { style = "grid"; columns = 3; };
          Tools = { style = "grid"; columns = 3; };
          Infrastructure = { style = "grid"; columns = 2; };
        };
      };

      services = [
        {
          "Media" = [
            { "Jellyfin" = { icon = "jellyfin.png"; href = "https://media"; }; }
            { "Sonarr" = { icon = "sonarr.png"; href = "https://sonarr"; }; }
            { "Radarr" = { icon = "radarr.png"; href = "https://radarr"; }; }
            { "Prowlarr" = { icon = "prowlarr.png"; href = "https://prowlarr"; }; }
          ];
        }
        {
          "Tools" = [
            { "Vaultwarden" = { icon = "vaultwarden.png"; href = "https://vault"; }; }
            { "Paperless" = { icon = "paperless.png"; href = "https://paperless"; }; }
            { "n8n" = { icon = "n8n.png"; href = "https://n8n"; }; }
            { "Miniflux" = { icon = "miniflux.png"; href = "https://miniflux"; }; }
          ];
        }
        {
          "Infrastructure" = [
            { "Pocket-ID" = { icon = "pocket-id.png"; href = "https://auth"; }; }
            { "Blocky" = { icon = "blocky.png"; href = "https://dns"; }; }
          ];
        }
      ];
    };

    services.caddy.virtualHosts."${cfg.host}".extraConfig = ''
      import admin_auth
      reverse_proxy localhost:${toString cfg.port}
    '';
  };
}
