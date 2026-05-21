# ---NIXMETA
---
domain: 00
id: "NIXH-00-COR-001"
title: "Core Foundation"
type: module
status: draft
complexity: 3
reviewed: YYYY-MM-DD
tags:
  - core
  - foundation
  - nix-tuning
  - zram
  - boot
description: "Core system: configs, ports, nix-tuning, zram-swap, boot-safeguard, shell aliases"
provides:
  - my.core.enable
  - my.core.configs
  - my.core.ports
requires:
 []
links:
  adr: ADR-00-core.md
  guide: 00-core.md
  module: modules/00-core.nix
---
# ---ENDNIXMETA

---
#
# PURPOSE: Core system: configs, ports, nix-tuning, zram, boot-safeguard.
# Key decisions: docs/adr/ADR-00-core.md

{ config, lib, pkgs, ... }:

# ── Core Foundation Module ─────────────────────────────────────────────
# SSoT für: configs, ports, nix-tuning, zram-swap, boot-safeguard

let
  cfg = config.my.core;
in {

  options.my.core = {
    enable = lib.mkEnableOption "core foundation module";

    # ── Bastelmodus ───────────────────────────────────────────────────
    bastelmodus = lib.mkOption {
      type        = lib.types.bool;
      default     = false;
      description = "Master switch: Firewall AUS, Sudo PASSWORDLESS.";
    };

    # ── Identity ──────────────────────────────────────────────────────
    identity = {
      host      = lib.mkOption { type = lib.types.str; default = "q958"; };
      domain    = lib.mkOption { type = lib.types.str; default = "m7c5.de"; };
      subdomain = lib.mkOption { type = lib.types.str; default = "nix"; };
      email     = lib.mkOption { type = lib.types.str; default = ""; };
      user      = lib.mkOption { type = lib.types.str; default = "moritz"; };
    };

    # ── Network CIDRs ─────────────────────────────────────────────────
    network = {
      lanCidrs     = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12" ]; };
      tailnetCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "100.64.0.0/10" ]; };
    };

    # ── Hardware ──────────────────────────────────────────────────────
    hardware = {
      cpuType = lib.mkOption { type = lib.types.enum [ "intel" "amd" "arm" ]; default = "intel"; };
      intelGpu = lib.mkOption { type = lib.types.bool; default = true; };
      ramGB    = lib.mkOption { type = lib.types.int; default = 16; };
    };

    # ── Ports ─────────────────────────────────────────────────────────
    ports = lib.mkOption {
      type = lib.types.attrsOf lib.types.port;
      default = {
        ssh         = 53844;
        edgeHttps   = 443;
        jellyfin    = 20096;
        vaultwarden = 20002;
        n8n         = 20017;
        paperless   = 20981;
        sonarr      = 20989;
        radarr      = 20878;
        prowlarr    = 20696;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    # ── Nix Tuning (Binary-Only Policy) ───────────────────────────────
    nix.settings = {
      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      max-jobs               = lib.mkForce 0;
      connect-timeout        = 5;
      builders-use-substitutes = true;
      auto-optimise-store    = true;
      experimental-features  = [ "nix-command" "flakes" "auto-allocate-uids" "cgroups" ];
      sandbox                = true;
      trusted-users          = [ "root" cfg.identity.user ];
    };

    nix.daemonCPUSchedPolicy = "idle";
    nix.daemonIOSchedClass   = "idle";

    nix.gc = {
      automatic    = true;
      dates        = "weekly";
      options      = "--delete-older-than 14d";
      persistent   = true;
    };

    # ── Boot Safeguard ────────────────────────────────────────────────
    boot.loader.systemd-boot = {
      configurationLimit = lib.mkForce 5;
      memtest.enable     = true;
      consoleMode        = "max";
    };

    # ── ZRAM Swap ─────────────────────────────────────────────────────
    zramSwap = {
      enable          = true;
      algorithm       = "zstd";
      priority        = 100;
      memoryPercent   =
        if cfg.hardware.ramGB <= 4 then 75
        else if cfg.hardware.ramGB <= 8 then 50
        else 25;
    };

    # ── Bastelmodus Warning ──────────────────────────────────────────
    systemd.services.bastelmodus-alarm = lib.mkIf cfg.bastelmodus {
      description = "Warn all terminals about bastelmodus";
      serviceConfig.Type = "oneshot";
      script = ''
        wall "⚠️ BASTELMODUS AKTIV: Firewall AUS. Sudo PASSWORDLESS."
      '';
    };

    # ── Shell Premium Aliases ─────────────────────────────────────────
    programs.bash.shellAliases = {
      nsw   = "sudo nixos-rebuild switch";
      ntest = "sudo nixos-rebuild test";
      ndry  = "sudo nixos-rebuild dry-run";
      nboot = "sudo nixos-rebuild boot";
      nup   = "nix flake update";
      nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
      nsw-safe = "sudo nixos-rebuild switch";  # TODO: mit boot-space-check verbinden
    };

    environment.systemPackages = with pkgs; [
      nix-tree nix-diff nixfmt-classic nix-output-monitor
      htop btop bat eza ripgrep fd duf dust fastfetch
      git curl wget tree unzip file lsof ncdu
    ];
  };
}
