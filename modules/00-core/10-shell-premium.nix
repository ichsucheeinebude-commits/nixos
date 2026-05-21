# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-029"
# title: "Shell Premium"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [core,shell,fastfetch,aliases,motd]
# description: "Advanced shell workflow with fastfetch MOTD, service status health-checks, and power-user aliases."
# path: "modules/00-core/10-shell-premium.nix"
# provides: [my.core.shell.premium]
# requires: [my.core.identity]
# links:
#   adr: docs/adr/ADR-10-shell-premium.md
#   guide: docs/guides/10-shell-premium.md
#   module: modules/00-core/10-shell-premium.nix
#   upstream: https://github.com/ryan4yin/nix-config/tree/main/modules/nixos/base/shell
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Standard-Shell-Login zeigt wenig bis keine Informationen. Für Homelab-Betrieb
# ist schnelle Orientierung entscheidend: Welcher Host? Welche Services laufen?
# Welche IPs sind relevant?
#
# ### Entscheidung
#
# **Shell-Premium Pattern:**
# 1.  **Fastfetch MOTD** — Custom JSON-Config mit LAN IP, Dashboard-URL, Hardware-Info.
# 2.  **Service-Checker** — Bash-Skript das kritische Services prüft und ✅/❀ ausgibt.
# 3.  **Alias-Suite** — Konsistente Shortcuts für nixos-rebuild, git, ls, cat, etc.
# 4.  **Tool-Upgrades** — eza statt ls, bat statt cat, duf statt df, dust statt du.
#
# ### SRE-Standards
#
# - Alle Tools kommen aus Nixpkgs (reproduzierbar, keine System-Abhängigkeiten).
# - Fastfetch-Config wird als writeText generiert (deklarativ, versioniert).
# - Service-Checker ist ein writeShellScriptBin (kein globales PATH-Problem).
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  domain = config.my.core.identity.domain;
  host = config.my.core.identity.host;

  fastfetchConfig = pkgs.writeText "fastfetch-homelab.jsonc" (builtins.toJSON {
    logo = { source = "nixos"; padding = { top = 1; left = 2; }; };
    display = { separator = " ➜ "; color = { keys = "blue"; title = "green"; }; };
    modules = [
      { type = "title"; format = "{user-name}@{host-name}"; } "separator"
      { type = "os"; key = "OS"; } { type = "kernel"; key = "Kernel"; } { type = "uptime"; key = "Uptime"; }
      { type = "packages"; key = "Packages"; } { type = "shell"; key = "Shell"; } "break"
      { type = "cpu"; key = "CPU"; } { type = "gpu"; key = "GPU"; } { type = "memory"; key = "Memory"; }
      { type = "disk"; key = "Disk (/)"; folders = "/"; } "break"
      { type = "localip"; key = "LAN IP"; compact = true; } "break"
      { type = "custom"; format = "https://${domain}"; key = "Dashboard"; } "break" "colors"
    ];
  });

  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    CRITICAL_SERVICES=("sshd:SSH" "caddy:Caddy" "tailscaled:Tailscale" "fail2ban:Fail2ban")
    echo -e "\n🔧 Service Status:\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for entry in "''${CRITICAL_SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service" 2>/dev/null; then
        echo "  ✅ $label"
      else
        echo "  ❌ $label (FEHLER!)"
      fi
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
in
{
  options.my.core.shell.premium = {
    enable = lib.mkEnableOption "Advanced Shell Features (Fastfetch, Service Checks, Power Aliases)";
  };

  config = lib.mkIf config.my.core.shell.premium.enable {
    programs.bash.shellAliases = {
      # ── NixOS ──
      nsw   = "sudo nixos-rebuild switch";
      ntest = "sudo nixos-rebuild test";
      ndry  = "sudo nixos-rebuild dry-run";
      nboot = "sudo nixos-rebuild boot";
      nup   = "nix flake update";
      nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
      nopt  = "sudo nix-store --optimise";
      ngen  = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      ncfg  = "cd /etc/nixos";
      ngit  = "cd /etc/nixos && git status -sb";
      nlog  = "journalctl -xef";

      # ── Git ──
      gs = "git status -sb";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --decorate --all -n 10";

      # ── Tool Upgrades ──
      ls   = "${pkgs.eza}/bin/eza --icons";
      ll   = "${pkgs.eza}/bin/eza -la --icons --git";
      tree = "${pkgs.eza}/bin/eza --tree --icons";
      cat  = "${pkgs.bat}/bin/bat --paging=never";
      less = "${pkgs.bat}/bin/bat";
      top  = "${pkgs.htop}/bin/htop";
      df   = "${pkgs.duf}/bin/duf";
      du   = "${pkgs.dust}/bin/dust";

      # ── System ──
      sysinfo  = "${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}";
      services = "${serviceStatusScript}/bin/check-services";
      ports    = "sudo ss -tulpn";
    };

    programs.bash.interactiveShellInit = ''
      if [ -n "$SSH_CONNECTION" ] || [ "$TERM" = "xterm-256color" ]; then
        ${pkgs.fastfetch}/bin/fastfetch --config ${fastfetchConfig}
        ${serviceStatusScript}/bin/check-services
        echo "💡 Tipp: Nutze 'aliases' für eine Liste aller Shortcuts"
      fi
    '';

    environment.systemPackages = with pkgs; [
      bat eza ripgrep fd duf dust htop btop
      nix-tree nix-diff nixfmt-classic nix-output-monitor
      fastfetch micro git curl wget tree unzip file lsof ncdu
    ];
  };
}
