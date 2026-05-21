# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-027"
# title: "Service Registry"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [registry,switchboard,feature-flags,hardware-profiles]
# description: "Master switchboard: declarative toggles for all services, hardware profiles, and networking features."
# path: "modules/00-core/04-registry.nix"
# provides: [my.services, my.profiles]
# requires: []
# links:
#   module: modules/00-core/04-registry.nix
# source: _meta/00-core/registry.nix (NIXH-00-COR-027)
# ---
# ---ENDNIXMETA
{ lib, ... }:
{
  options.my = {
    # ── Service Toggles ──
    services = {
      # Infrastructure
      caddy.enable = lib.mkEnableOption "Caddy edge proxy";
      pocketId.enable = lib.mkEnableOption "Pocket-ID OIDC provider";
      postgresql.enable = lib.mkEnableOption "PostgreSQL database";
      valkey.enable = lib.mkEnableOption "Valkey (Redis fork) cache";
      clamav.enable = lib.mkEnableOption "ClamAV antivirus";
      secretIngest.enable = lib.mkEnableOption "Secret landing zone watcher";
      kernelSlim.enable = lib.mkEnableOption "Kernel slim/hardening";
      configMerger.enable = lib.mkEnableOption "Config merger service";
      mediaStack.enable = lib.mkEnableOption "Media stack layout";
      arrWire.enable = lib.mkEnableOption "ARR API wiring helper";
      backup.enable = lib.mkEnableOption "Restic backup";
      netdata.enable = lib.mkEnableOption "Netdata monitoring";
      scrutiny.enable = lib.mkEnableOption "S.M.A.R.T monitoring";
      uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma";
      aiAgents.enable = lib.mkEnableOption "Ollama + Claude Code";
      semaphore.enable = lib.mkEnableOption "Ansible Semaphore";
      miniflux.enable = lib.mkEnableOption "Miniflux RSS reader";
      linkwarden.enable = lib.mkEnableOption "Linkwarden bookmarks";
      karakeep.enable = lib.mkEnableOption "Karakeep bookmarks";
      matrixConduit.enable = lib.mkEnableOption "Matrix Conduit homeserver";
      monica.enable = lib.mkEnableOption "Monica CRM";
      couchdb.enable = lib.mkEnableOption "CouchDB";
      filebrowser.enable = lib.mkEnableOption "Filebrowser";

      # Hardware profiles
      hardwareProfile = lib.mkOption {
        type = lib.types.enum [ "q958" "generic" ];
        default = "generic";
        description = "Hardware profile selection.";
      };
    };

    # ── Hardware Profiles ──
    profiles = {
      hardware.q958.enable = lib.mkEnableOption "Fujitsu Q958 optimizations (Intel i5-4570T, 16GB RAM)";
      networking = {
        systemd-networkd.enable = lib.mkEnableOption "systemd-networkd for fast boot";
        vpn-confinement.enable = lib.mkEnableOption "VPN network namespace isolation";
        reverseProxy = lib.mkOption {
          type = lib.types.enum [ "caddy" "traefik" "nginx" "none" ];
          default = "caddy";
          description = "Reverse proxy selection.";
        };
      };
    };

    # ── Identity (central SSoT) ──
    configs = {
      identity = {
        host = lib.mkOption { type = lib.types.str; default = "nixhome"; description = "Hostname."; };
        user = lib.mkOption { type = lib.types.str; default = "moritz"; description = "Primary user."; };
        domain = lib.mkOption { type = lib.types.str; default = "m7c5.de"; description = "Primary domain."; };
        subdomain = lib.mkOption { type = lib.types.str; default = "nix"; description = "Subdomain."; };
        email = lib.mkOption { type = lib.types.str; default = "admin@m7c5.de"; description = "Admin email."; };
      };
      server = {
        lanIP = lib.mkOption { type = lib.types.str; default = "10.254.0.1"; description = "LAN IP address."; };
        tailscaleIP = lib.mkOption { type = lib.types.str; default = "100.64.3.155"; description = "Tailscale IP."; };
      };
      network = {
        lanCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "10.254.0.0/24" "192.168.1.0/24" ]; };
        tailnetCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "100.64.0.0/10" ]; };
      };
      paths = {
        mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/media"; };
        storagePool = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; };
        stateDir = lib.mkOption { type = lib.types.str; default = "/data/state"; };
      };
      bastelmodus = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = "Workshop mode — disables firewall for testing.";
      };
      hardware = {
        cpuType = lib.mkOption { type = lib.types.enum [ "intel" "amd" ]; default = "intel"; };
        ramGB = lib.mkOption { type = lib.types.int; default = 16; };
        intelGpu = lib.mkOption { type = lib.types.bool; default = true; description = "Intel iGPU available."; };
      };
      vpn.privado = {
        publicKey = lib.mkOption { type = lib.types.str; default = ""; };
        endpoint = lib.mkOption { type = lib.types.str; default = ""; };
        address = lib.mkOption { type = lib.types.str; default = ""; };
        dns = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; };
      };
    };
  };
}
