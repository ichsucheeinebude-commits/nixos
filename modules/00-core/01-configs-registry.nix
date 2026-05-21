# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-002"
# title: "Identity & Hardware Registry"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,identity,hardware,registry,ports]
# description: "Central registry for identity, hardware specs, network, and service toggles."
# path: "modules/00-core/01-configs-registry.nix"
# provides: [my.core.identity,my.core.hardware,my.core.server,my.core.network,my.core.ports,my.core.services]
# requires: []
# links:
#   adr: docs/adr/ADR-00-002-002.md
#   guide: docs/guides/GUIDE-00-002-002.md
#   module: modules/00-core/01-configs-registry.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
let
  idCfg = config.my.core.identity;
in
{
  options.my.core.identity = {
    host = lib.mkOption { type = lib.types.str; default = ""; description = "Host name (e.g. q958)."; };
    domain = lib.mkOption { type = lib.types.str; default = ""; description = "Base domain (e.g. m7c5.de)."; };
    subdomain = lib.mkOption { type = lib.types.str; default = "nix"; description = "Subdomain prefix for services."; };
    email = lib.mkOption { type = lib.types.str; default = ""; description = "Admin email address."; };
    user = lib.mkOption { type = lib.types.str; default = "root"; description = "Primary user name."; };
    lanIP = lib.mkOption { type = lib.types.str; default = ""; description = "Server LAN IP address."; };
  };

  options.my.core.hardware = {
    cpuType = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "intel" "amd" "arm" ]);
      default = null;
      description = "CPU architecture for microcode and driver selection.";
    };
    intelGpu = lib.mkOption { type = lib.types.bool; default = false; description = "Intel GPU present (enables i915/QSV)."; };
    ramGB = lib.mkOption { type = lib.types.int; default = 0; description = "Installed RAM in GB."; };
    profile = lib.mkOption { type = lib.types.str; default = "generic"; description = "Hardware profile name."; };
  };

  options.my.core.server = {
    lanIP = lib.mkOption { type = lib.types.str; default = ""; description = "Alias for identity.lanIP."; };
  };

  options.my.core.network = {
    lanCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Trusted LAN CIDR blocks."; };
  };

  options.my.core.ports = {
    ssh = lib.mkOption { type = lib.types.port; default = 22; description = "SSH port."; };
  };

  # Service toggle registry — every service in the boilerplate registers here.
  options.my.core.services = {
    blocky.enable = lib.mkEnableOption "Blocky DNS";
    caddy.enable = lib.mkEnableOption "Caddy reverse proxy";
    pocketId.enable = lib.mkEnableOption "Pocket-ID (OIDC)";
    postgresql.enable = lib.mkEnableOption "PostgreSQL database";
    fail2ban.enable = lib.mkEnableOption "Fail2ban";
    vaultwarden.enable = lib.mkEnableOption "Vaultwarden";
    jellyfin.enable = lib.mkEnableOption "Jellyfin";
    zigbeeStack.enable = lib.mkEnableOption "Zigbee2MQTT + Mosquitto";
    ntfy.enable = lib.mkEnableOption "ntfy-sh alerting";
    gatus.enable = lib.mkEnableOption "Gatus health dashboard";
    netdata.enable = lib.mkEnableOption "Netdata telemetry";
    scrutiny.enable = lib.mkEnableOption "Scrutiny SMART monitoring";
    uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma";
    vector.enable = lib.mkEnableOption "Vector log aggregator";
    paperless.enable = lib.mkEnableOption "Paperless-ngx";
    n8n.enable = lib.mkEnableOption "n8n automation";
    homeAssistant.enable = lib.mkEnableOption "Home Assistant";
    readeck.enable = lib.mkEnableOption "Readeck";
    matrixConduit.enable = lib.mkEnableOption "Matrix Conduit";
    miniflux.enable = lib.mkEnableOption "Miniflux RSS";
    linkding.enable = lib.mkEnableOption "Linkding bookmarks";
    monica.enable = lib.mkEnableOption "Monica CRM";
    karakeep.enable = lib.mkEnableOption "Karakeep";
    forgejo.enable = lib.mkEnableOption "Forgejo Git";
    semaphore.enable = lib.mkEnableOption "Semaphore Ansible";
    cockpit.enable = lib.mkEnableOption "Cockpit admin";
    amp.enable = lib.mkEnableOption "AMP game servers";
    arrStack.enable = lib.mkEnableOption "Arr media stack";
    downloads.enable = lib.mkEnableOption "Download stack (SABnzbd)";
    streaming.enable = lib.mkEnableOption "Streaming stack";
    discovery.enable = lib.mkEnableOption "Jellyseerr discovery";
    storageMover.enable = lib.mkEnableOption "Smart storage mover";
    dnsAutomation.enable = lib.mkEnableOption "DNS automation";
    ddnsUpdater.enable = lib.mkEnableOption "DDNS updater";
    sonarr.enable = lib.mkEnableOption "Sonarr";
    radarr.enable = lib.mkEnableOption "Radarr";
    prowlarr.enable = lib.mkEnableOption "Prowlarr";
    backup.enable = lib.mkEnableOption "Restic backup";
    tpm2.enable = lib.mkEnableOption "TPM2 sealing";
    zram.enable = lib.mkEnableOption "ZRAM swap";
    memtest.enable = lib.mkEnableOption "Memtest86+ boot entry";
    secrets.enable = lib.mkEnableOption "SOPS secrets management";
    sshRescue.enable = lib.mkEnableOption "SSH rescue service";
  };

  # Backward-compat aliases (read-only)
  config = lib.mkIf config.my.core.principles.enable {
    my.core.server.lanIP = lib.mkDefault config.my.core.identity.lanIP;
  };
}

