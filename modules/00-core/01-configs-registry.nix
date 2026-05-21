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
#   adr: docs/adr/ADR-01-configs-registry.md
#   guide: docs/guides/01-configs-registry.md
#   module: modules/00-core/01-configs-registry.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: MODULARITÄT OHNE SCHMERZ (KISS)
#
# In herkömmlichen Nix-Systemen musst du jede neue Datei manuell in einer Liste eintragen. In unserem System ist das vorbei:
# - **Prinzip:** "Jede Datei ist ein Modul".
# - **Aktion:** Erstelle eine `.nix` Datei im Ordner `features/` – sie wird sofort vom System erkannt und geladen.
# - **Vorteil:** Du kannst dich auf das Konfigurieren konzentrieren, anstatt dich um Import-Strukturen zu kümmern.
#
# ---
# ### A. Die Engine: `flake-parts` & `den`
#
# Wir nutzen `flake-parts` als Basis und das `den` Framework zur Kontext-Steuerung.
# - **Auto-Import:** Integration von `import-tree`, um das gesamte Verzeichnis `./modules` rekursiv zu evaluieren.
# - **Deferred Modules:** Wir nutzen den Typ `deferredModule` aus Nixpkgs für Sub-Module, um Konflikte beim Mergen von Attributen (z.B. Firewall-Regeln) zu minimieren.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.core.identity = {
    host = lib.mkOption { type = lib.types.str; default = ""; description = "Host name."; };
    domain = lib.mkOption { type = lib.types.str; default = ""; description = "Base domain."; };
    subdomain = lib.mkOption { type = lib.types.str; default = "nix"; description = "Subdomain prefix."; };
    email = lib.mkOption { type = lib.types.str; default = ""; description = "Admin email."; };
    user = lib.mkOption { type = lib.types.str; default = "root"; description = "Primary user name."; };
    lanIP = lib.mkOption { type = lib.types.str; default = ""; description = "Server LAN IP."; };
  };

  options.my.core.hardware = {
    cpuType = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "intel" "amd" "arm" ]);
      default = null;
      description = "CPU architecture for microcode/driver selection.";
    };
    intelGpu = lib.mkOption { type = lib.types.bool; default = false; description = "Intel GPU present."; };
    ramGB = lib.mkOption { type = lib.types.int; default = 0; description = "Installed RAM in GB."; };
    profile = lib.mkOption { type = lib.types.str; default = "generic"; description = "Hardware profile name."; };
  };

  options.my.core.server = {
    lanIP = lib.mkOption { type = lib.types.str; default = ""; description = "Alias for identity.lanIP."; };
  };

  options.my.core.network = {
    lanCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Trusted LAN CIDRs."; };
  };

  options.my.core.ports = {
    ssh = lib.mkOption { type = lib.types.port; default = 22; description = "SSH port."; };
    adguard = lib.mkOption { type = lib.types.port; default = 3053; description = "AdGuard Home web UI port."; };
    olivetin = lib.mkOption { type = lib.types.port; default = 1337; description = "OliveTin control panel port."; };
    linkwarden = lib.mkOption { type = lib.types.port; default = 3000; description = "Linkwarden port."; };
    openWebui = lib.mkOption { type = lib.types.port; default = 3080; description = "Open WebUI port."; };
    ollama = lib.mkOption { type = lib.types.port; default = 11434; description = "Ollama API port."; };
  };

  options.my.core.services = {
    blocky.enable = lib.mkEnableOption "Blocky DNS";
    caddy.enable = lib.mkEnableOption "Caddy reverse proxy";
    pocketId.enable = lib.mkEnableOption "Pocket-ID (OIDC)";
    postgresql.enable = lib.mkEnableOption "PostgreSQL";
    fail2ban.enable = lib.mkEnableOption "Fail2ban";
    vaultwarden.enable = lib.mkEnableOption "Vaultwarden";
    jellyfin.enable = lib.mkEnableOption "Jellyfin";
    zigbeeStack.enable = lib.mkEnableOption "Zigbee2MQTT + Mosquitto";
    ntfy.enable = lib.mkEnableOption "ntfy-sh";
    gatus.enable = lib.mkEnableOption "Gatus";
    netdata.enable = lib.mkEnableOption "Netdata";
    scrutiny.enable = lib.mkEnableOption "Scrutiny";
    uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma";
    vector.enable = lib.mkEnableOption "Vector";
    paperless.enable = lib.mkEnableOption "Paperless-ngx";
    n8n.enable = lib.mkEnableOption "n8n";
    homeAssistant.enable = lib.mkEnableOption "Home Assistant";
    readeck.enable = lib.mkEnableOption "Readeck";
    matrixConduit.enable = lib.mkEnableOption "Matrix Conduit";
    miniflux.enable = lib.mkEnableOption "Miniflux";
    linkding.enable = lib.mkEnableOption "Linkding";
    monica.enable = lib.mkEnableOption "Monica";
    karakeep.enable = lib.mkEnableOption "Karakeep";
    forgejo.enable = lib.mkEnableOption "Forgejo";
    semaphore.enable = lib.mkEnableOption "Semaphore";
    cockpit.enable = lib.mkEnableOption "Cockpit";
    amp.enable = lib.mkEnableOption "AMP";
    arrStack.enable = lib.mkEnableOption "Arr media stack";
    downloads.enable = lib.mkEnableOption "Download stack";
    streaming.enable = lib.mkEnableOption "Streaming stack";
    discovery.enable = lib.mkEnableOption "Jellyseerr";
    storageMover.enable = lib.mkEnableOption "Storage mover";
    dnsAutomation.enable = lib.mkEnableOption "DNS automation";
    ddnsUpdater.enable = lib.mkEnableOption "DDNS updater";
    sonarr.enable = lib.mkEnableOption "Sonarr";
    radarr.enable = lib.mkEnableOption "Radarr";
    prowlarr.enable = lib.mkEnableOption "Prowlarr";
    backup.enable = lib.mkEnableOption "Restic backup";
    tpm2.enable = lib.mkEnableOption "TPM2";
    zram.enable = lib.mkEnableOption "ZRAM swap";
    memtest.enable = lib.mkEnableOption "Memtest86+";
    secrets.enable = lib.mkEnableOption "SOPS secrets";
    sshRescue.enable = lib.mkEnableOption "SSH rescue";
    shellPremium.enable = lib.mkEnableOption "Advanced shell (fastfetch, aliases)";
    symbiosis.enable = lib.mkEnableOption "Hardware abstraction";
    adguardhome.enable = lib.mkEnableOption "AdGuard Home DNS";
    tailscale.enable = lib.mkEnableOption "Tailscale VPN";
    clamav.enable = lib.mkEnableOption "ClamAV antivirus";
    secretIngest.enable = lib.mkEnableOption "Secret ingest pipeline";
    linkwarden.enable = lib.mkEnableOption "Linkwarden bookmarks";
    olivetin.enable = lib.mkEnableOption "OliveTin control panel";
    cloudflared.enable = lib.mkEnableOption "Cloudflare Tunnel";
    landingZone.enable = lib.mkEnableOption "Static landing page";
    openWebui.enable = lib.mkEnableOption "Open WebUI for LLMs";
    dnsMap.enable = lib.mkEnableOption "DNS subdomain mapping";
    binaryOnly.enable = lib.mkEnableOption "Binary-only Nix builds";
    securityAssertions.enable = lib.mkEnableOption "Security assertion enforcement";
    libHelpers.enable = lib.mkEnableOption "mkService library";
    configMerger.enable = lib.mkEnableOption "Config merger (Nix + JSON overrides)";
  };

  config = lib.mkIf config.my.core.principles.enable {
    my.core.server.lanIP = lib.mkDefault config.my.core.identity.lanIP;
  };
}
