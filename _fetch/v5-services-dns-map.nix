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

{ config, ... }: 
let
 identity = config.my.configs.identity;
 domain = identity.domain;
 sub = identity.subdomain;
 d = "${sub}.${domain}";
in
{
  inherit domain sub;
  dnsMapping = {
    # 📺 Media
    jellyfin = "jellyfin.${d}";
    sonarr = "sonarr.${d}";
    radarr = "radarr.${d}";
    prowlarr = "prowlarr.${d}";
    readarr = "readarr.${d}";
    lidarr = "lidarr.${d}";
    audiobookshelf = "audiobookshelf.${d}";
    sabnzbd = "sabnzbd.${d}";
    jellyseerr = "jellyseerr.${d}";
    
    # 🔐 Security & Base
    vault = "vault.${d}";
    auth = "auth.${d}";
    status = "status.${d}";
    
    # 🛠️ Tools & Apps
    paperless = "paperless.${d}";
    n8n = "n8n.${d}";
    miniflux = "miniflux.${d}";
    monica = "monica.${d}";
    readeck = "readeck.${d}";
    matrix = "matrix.${d}";
    filebrowser = "filebrowser.${d}";
    homeassistant = "home.${d}";
    openwebui = "openwebui.${d}";
    
    # 📊 Monitoring & Admin
    dashboard = "dash.${d}";
    blocky = "dns.${d}";
    netdata = "netdata.${d}";
    scrutiny = "scrutiny.${d}";
    cockpit = "admin.${d}";
    ddns = "nix-ddns.${d}";
  };
}
