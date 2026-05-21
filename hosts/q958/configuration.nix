# ---NIXMETA
# ---
# domain: host
# id: "NIXH-HOST-Q958"
# title: "Host: q958 (Fujitsu Q958 Server)"
# type: host
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [host,q958,server]
# description: "Host configuration for Fujitsu Q958 server – overrides module options."
# path: "hosts/q958/configuration.nix"
# provides: []
# requires: [all modules]
# links:
#   module: hosts/q958/configuration.nix
# ---
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  imports = [
    ./hardware-nixos.nix
    # 00-core
    ../../modules/00-core/00-principles.nix
    ../../modules/00-core/01-configs-registry.nix
    ../../modules/00-core/02-nix-tuning.nix
    ../../modules/00-core/03-hardware-profile.nix
    ../../modules/00-core/04-boot-safeguards.nix
    ../../modules/00-core/05-tpm2.nix
    ../../modules/00-core/06-zram-swap.nix
    ../../modules/00-core/07-locale-system.nix
    ../../modules/00-core/08-users-shell.nix
    ../../modules/00-core/09-postgresql.nix
    # 10-network
    ../../modules/10-network/10-network.nix
    ../../modules/10-network/11-firewall.nix
    ../../modules/10-network/12-ssh.nix
    ../../modules/10-network/13-ssh-rescue.nix
    ../../modules/10-network/14-blocky.nix
    ../../modules/10-network/15-caddy.nix
    ../../modules/10-network/16-dns-automation.nix
    ../../modules/10-network/17-pocket-id.nix
    ../../modules/10-network/18-ddns-updater.nix
    ../../modules/10-network/19-zigbee-stack.nix
    # 20-security
    ../../modules/20-security/20-fail2ban.nix
    ../../modules/20-security/21-kernel-hardening.nix
    ../../modules/20-security/22-secrets.nix
    ../../modules/20-security/23-secrets-schema.nix
    # 30-storage
    ../../modules/30-storage/30-storage.nix
    ../../modules/30-storage/31-backup.nix
    ../../modules/30-storage/32-impermanence.nix
    ../../modules/30-storage/33-storage-policy.nix
    ../../modules/30-storage/34-storage-mover.nix
    # 40-monitoring
    ../../modules/40-monitoring/40-gatus.nix
    ../../modules/40-monitoring/41-netdata.nix
    ../../modules/40-monitoring/42-ntfy.nix
    ../../modules/40-monitoring/43-scrutiny.nix
    ../../modules/40-monitoring/44-vector.nix
    ../../modules/40-monitoring/45-uptime-kuma.nix
    # 50-media
    ../../modules/50-media/50-lib-media.nix
    ../../modules/50-media/51-arr-stack.nix
    ../../modules/50-media/52-download.nix
    ../../modules/50-media/53-streaming.nix
    ../../modules/50-media/54-discovery.nix
    ../../modules/50-media/55-jellyfin.nix
    ../../modules/50-media/56-sonarr.nix
    ../../modules/50-media/57-radarr.nix
    ../../modules/50-media/58-prowlarr.nix
    ../../modules/50-media/59-lidarr.nix
    # 60-apps
    ../../modules/60-apps/60-paperless.nix
    ../../modules/60-apps/61-n8n.nix
    ../../modules/60-apps/62-vaultwarden.nix
    ../../modules/60-apps/63-home-assistant.nix
    ../../modules/60-apps/64-readeck.nix
    ../../modules/60-apps/65-matrix-conduit.nix
    ../../modules/60-apps/66-miniflux.nix
    ../../modules/60-apps/67-linkding.nix
    ../../modules/60-apps/68-monica.nix
    ../../modules/60-apps/69-karakeep.nix
    # 70-forge
    ../../modules/70-forge/70-forgejo.nix
    ../../modules/70-forge/71-semaphore.nix
    ../../modules/70-forge/72-cockpit.nix
    # 80-gaming
    ../../modules/80-gaming/80-amp.nix
    ../../modules/80-gaming/81-amp-fhs.nix
    # 90-policy
    ../../modules/90-policy/90-forbidden-tech.nix
    ../../modules/90-policy/91-architecture-rules.nix
    ../../modules/90-policy/92-deferred-ops.nix
  ];

  # ─────────────────────────────────────────────────────────────────────
  # IDENTITY
  # ─────────────────────────────────────────────────────────────────────
  my.core.identity.host    = "q958";
  my.core.identity.domain  = "m7c5.de";
  my.core.identity.subdomain = "nix";
  my.core.identity.user    = "moritz";

  my.core.locale.timezone  = "Europe/Berlin";
  my.core.locale.default   = "de_DE.UTF-8";
  my.core.locale.keymap    = "de";

  my.core.hardware.cpuType = "intel";
  my.core.hardware.intelGpu = true;
  my.core.hardware.ramGB   = 16;
  my.core.hardware.profile = "q958";

  my.core.ports.ssh        = 53844;

  my.core.server.lanIP     = "192.168.1.100";
  my.core.network.lanCidrs = [ "192.168.1.0/24" ];

  # ─────────────────────────────────────────────────────────────────────
  # NETWORK OVERRIDES
  # ─────────────────────────────────────────────────────────────────────
  my.network.base.hostName = "q958";
  my.network.ssh.port      = 53844;
  my.network.firewall.allowedTCPPorts = [ 80 443 ];

  # ─────────────────────────────────────────────────────────────────────
  # BOOT (override defaults)
  # ─────────────────────────────────────────────────────────────────────
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;
  my.core.boot.configurationLimit      = 5;
  my.core.boot.memtest                 = true;

  # ─────────────────────────────────────────────────────────────────────
  # IMPERMANENCE
  # ─────────────────────────────────────────────────────────────────────
  my.storage.impermanence.enable   = true;
  my.storage.impermanence.ramfsSize = "4G";
  my.storage.impermanence.directories = [
    "/var/log"
    "/var/lib/nixos"
    "/var/lib/systemd/coredump"
    "/var/lib/sops-nix"
    "/etc/NetworkManager/system-connections"
    "/etc/ssh"
    "/home/moritz"
    "/etc/nixos"
  ];
  my.storage.impermanence.files = [
    "/etc/machine-id"
    "/etc/ssh/ssh_host_ed25519_key"
    "/etc/ssh/ssh_host_ed25519_key.pub"
    "/etc/ssh/ssh_host_rsa_key"
    "/etc/ssh/ssh_host_rsa_key.pub"
  ];

  fileSystems."/" = {
    device  = "none";
    fsType  = "tmpfs";
    options = [ "defaults" "size=4G" "mode=755" ];
  };

  # ─────────────────────────────────────────────────────────────────────
  # SOPS Secrets
  # ─────────────────────────────────────────────────────────────────────
  sops = {
    # defaultSopsFile = ../../secrets/q958.yaml;
    age.sshKeyPaths = [ "/persist/etc/ssh/ssh_host_ed25519_key" ];
  };

  system.stateVersion = "24.11";
}
