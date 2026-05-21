# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-10-GTW-007";
 title = "Homepage Dashboard";
 description = "Highly customizable application dashboard, fully declarative.";
 layer = 10;
 nixpkgs.category = "services/misc";
 capabilities = [ "web/dashboard" "observability/ui" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

 dnsMap = import ./dns-map.nix { inherit config; };
 host = dnsMap.dnsMapping.dashboard or "dash.${config.my.configs.identity.subdomain}.${config.my.configs.identity.domain}";
in
{
 options.my.meta.homepage = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for homepage module";
 };


  config = lib.mkIf config.my.services.homepage.enable {
    services.homepage-dashboard = {
      enable = true;
      environmentFile = config.my.secrets.files.sharedEnv;
      widgets = [ { resources = { cpu = true; memory = true; disk = "/"; uptime = true; }; } { search = { provider = "duckduckgo"; target = "_blank"; }; } ];
      services = [
        { "Media" = [ { "Jellyfin" = { icon = "jellyfin.png"; href = "https://${dnsMap.dnsMapping.jellyfin}"; }; } { "Sonarr" = { icon = "sonarr.png"; href = "https://${dnsMap.dnsMapping.sonarr}"; }; } { "Radarr" = { icon = "radarr.png"; href = "https://${dnsMap.dnsMapping.radarr}"; }; } { "Prowlarr" = { icon = "prowlarr.png"; href = "https://${dnsMap.dnsMapping.prowlarr}"; }; } { "Readarr" = { icon = "readarr.png"; href = "https://${dnsMap.dnsMapping.readarr}"; }; } { "Audiobookshelf" = { icon = "audiobookshelf.png"; href = "https://${dnsMap.dnsMapping.audiobookshelf}"; }; } ]; }
        { "Tools" = [ { "Vaultwarden" = { icon = "vaultwarden.png"; href = "https://${dnsMap.dnsMapping.vault}"; }; } { "Paperless" = { icon = "paperless.png"; href = "https://${dnsMap.dnsMapping.paperless}"; }; } { "n8n" = { icon = "n8n.png"; href = "https://${dnsMap.dnsMapping.n8n}"; }; } { "Miniflux" = { icon = "miniflux.png"; href = "https://${dnsMap.dnsMapping.miniflux}"; }; } { "Monica" = { icon = "monica.png"; href = "https://${dnsMap.dnsMapping.monica}"; }; } ]; }
        { "Infrastructure" = [ { "Pocket-ID" = { icon = "pocket-id.png"; href = "https://${dnsMap.dnsMapping.auth}"; }; } { "Netdata" = { icon = "netdata.png"; href = "https://netdata.${config.my.configs.identity.domain}"; }; } { "Blocky" = { icon = "blocky.png"; href = "https://${dnsMap.dnsMapping.blocky or "dns.${config.my.configs.identity.domain}"}"; }; } ]; }
      ];
      settings = { title = "nixhome dashboard"; layout = { Media = { style = "grid"; columns = 3; }; Tools = { style = "grid"; columns = 3; }; Infrastructure = { style = "grid"; columns = 2; }; }; };
    };
    services.caddy.virtualHosts."${host}" = {
      extraConfig = ''
        import admin_auth
        reverse_proxy 127.0.0.1:${toString config.my.ports.homepage}
      '';
    };

    systemd.services.homepage-dashboard.restartTriggers = [
      config.my.secrets.files.sharedEnv
    ];
  };
}
