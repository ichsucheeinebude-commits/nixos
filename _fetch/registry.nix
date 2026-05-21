{lib, ...}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-027";
    title = "Registry";
    description = "Master switchboard for all system services with declarative toggles and hardware profiles.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["system/feature-flags" "architecture/modularity" "ssot/registry"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };
in {
  options.my.meta.registry = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };

  options.my = {
    profiles = {
      hardware.q958.enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable Fujitsu Q958 optimizations.";
      };
      networking = {
        systemd-networkd.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Use systemd-networkd for fast network boot.";
        };
        vpn-confinement.enable = lib.mkOption {
          type = lib.types.bool;
          default = true;
          description = "Enable Wireguard namespace isolation.";
        };
        reverseProxy = lib.mkOption {
          type = lib.types.enum ["caddy" "none"];
          default = "caddy";
          description = "Global reverse proxy selector.";
        };
      };
    };

    services = {
      adguardhome.enable = lib.mkEnableOption "AdGuard Home (DNS Filter)";
      aiAgents.enable = lib.mkEnableOption "AI Agents (Ollama/Claude)";
      audiobookshelf.enable = lib.mkEnableOption "Audiobookshelf (Media)";
      backup.enable = lib.mkEnableOption "Restic Backup (SRE Expert)";
      bootSafeguard.enable = lib.mkEnableOption "Boot Partition Protection";
      clamav.enable = lib.mkEnableOption "ClamAV (Antivirus)";
      cloudflaredTunnel.enable = lib.mkEnableOption "Cloudflare Tunnel (Ingress)";
      cockpit.enable = lib.mkEnableOption "Cockpit (Web Admin)";
      configMerger.enable = lib.mkEnableOption "Config Merger (Runtime)";
      ddnsUpdater.enable = lib.mkEnableOption "DDNS Updater";
      dnsAutomation.enable = lib.mkEnableOption "DNS Automation (Cloudflare)";
      fail2ban.enable = lib.mkEnableOption "Fail2ban (Hardening)";
      filebrowser.enable = lib.mkEnableOption "Filebrowser (Explorer)";
      homeAssistant.enable = lib.mkEnableOption "Home Assistant (IoT)";
      homepage.enable = lib.mkEnableOption "Homepage Dashboard";
      jellyfin.enable = lib.mkEnableOption "Jellyfin (Media)";
      jellyseerr.enable = lib.mkEnableOption "Jellyseerr (Requests)";
      karakeep.enable = lib.mkEnableOption "Karakeep (Bookmarks)";
      kernelSlim.enable = lib.mkEnableOption "Kernel Slim (Hardened)";
      lidarr.enable = lib.mkEnableOption "Lidarr (Music)";
      linkding.enable = lib.mkEnableOption "Linkding (Bookmarks)";
      linkwarden.enable = lib.mkEnableOption "Linkwarden (Archive)";
      matrixConduit.enable = lib.mkEnableOption "Matrix Conduit (Chat)";
      mediaStack.enable = lib.mkEnableOption "Media Stack Layout";
      miniflux.enable = lib.mkEnableOption "Miniflux (RSS)";
      monica.enable = lib.mkEnableOption "Monica (CRM)";
      n8n.enable = lib.mkEnableOption "n8n (Workflows)";
      netdata.enable = lib.mkEnableOption "Netdata (Real-time Mon)";
      olivetin.enable = lib.mkEnableOption "OliveTin (Control Panel)";
      paperless.enable = lib.mkEnableOption "Paperless-ngx (Docs)";
      pocketId.enable = lib.mkEnableOption "Pocket-ID (OIDC)";
      postgresql.enable = lib.mkEnableOption "PostgreSQL (DB Cluster)";
      prowlarr.enable = lib.mkEnableOption "Prowlarr (Indexer)";
      radarr.enable = lib.mkEnableOption "Radarr (Movies)";
      readarr.enable = lib.mkEnableOption "Readarr (Books)";
      readeck.enable = lib.mkEnableOption "Readeck (Read-it-later)";
      recyclarr.enable = lib.mkEnableOption "Recyclarr (Arr-Profiles)";
      sabnzbd.enable = lib.mkEnableOption "SABnzbd (Usenet)";
      scrutiny.enable = lib.mkEnableOption "Scrutiny (SMART Mon)";
      secretIngest.enable = lib.mkEnableOption "Secret Ingest Agent";
      semaphore.enable = lib.mkEnableOption "Semaphore (Ansible)";
      sonarr.enable = lib.mkEnableOption "Sonarr (TV)";
      sshRescue.enable = lib.mkEnableOption "SSH Recovery Window";
      storagePool.enable = lib.mkEnableOption "MergerFS Storage Pool";
      tailscale.enable = lib.mkEnableOption "Tailscale (Mesh VPN)";
      uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma (Mon)";
      valkey.enable = lib.mkEnableOption "Valkey (Redis DB)";
      vaultwarden.enable = lib.mkEnableOption "Vaultwarden (Passwords)";
      zigbeeStack.enable = lib.mkEnableOption "Zigbee Stack (MQTT/Z2M)";
    };
  };

  config.my.services = {
    adguardhome.enable = lib.mkDefault true;
    aiAgents.enable = lib.mkDefault true;
    audiobookshelf.enable = lib.mkDefault true;
    backup.enable = lib.mkDefault true;
    bootSafeguard.enable = lib.mkDefault true;
    clamav.enable = lib.mkDefault true;
    cloudflaredTunnel.enable = lib.mkDefault true;
    cockpit.enable = lib.mkDefault true;
    configMerger.enable = lib.mkDefault true;
    ddnsUpdater.enable = lib.mkDefault true;
    dnsAutomation.enable = lib.mkDefault true;
    fail2ban.enable = lib.mkDefault true;
    filebrowser.enable = lib.mkDefault true;
    homeAssistant.enable = lib.mkDefault true;
    homepage.enable = lib.mkDefault true;
    jellyfin.enable = lib.mkDefault true;
    jellyseerr.enable = lib.mkDefault true;
    karakeep.enable = lib.mkDefault true;
    kernelSlim.enable = lib.mkDefault true;
    lidarr.enable = lib.mkDefault true;
    linkding.enable = lib.mkDefault true;
    linkwarden.enable = lib.mkDefault true;
    matrixConduit.enable = lib.mkDefault true;
    mediaStack.enable = lib.mkDefault true;
    miniflux.enable = lib.mkDefault true;
    monica.enable = lib.mkDefault true;
    n8n.enable = lib.mkDefault true;
    netdata.enable = lib.mkDefault true;
    olivetin.enable = lib.mkDefault true;
    paperless.enable = lib.mkDefault true;
    pocketId.enable = lib.mkDefault true;
    postgresql.enable = lib.mkDefault true;
    prowlarr.enable = lib.mkDefault true;
    radarr.enable = lib.mkDefault true;
    readarr.enable = lib.mkDefault true;
    readeck.enable = lib.mkDefault true;
    recyclarr.enable = lib.mkDefault true;
    sabnzbd.enable = lib.mkDefault true;
    scrutiny.enable = lib.mkDefault true;
    secretIngest.enable = lib.mkDefault true;
    semaphore.enable = lib.mkDefault true;
    sonarr.enable = lib.mkDefault true;
    sshRescue.enable = lib.mkDefault true;
    storagePool.enable = lib.mkDefault true;
    tailscale.enable = lib.mkDefault true;
    uptimeKuma.enable = lib.mkDefault true;
    valkey.enable = lib.mkDefault true;
    vaultwarden.enable = lib.mkDefault true;
    zigbeeStack.enable = lib.mkDefault true;
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:ee86652300b80b9b99b7ba914eef119db47bc3caa435dbf45293e85b038b32cd
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

