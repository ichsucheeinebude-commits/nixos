# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-029"
# title: "Shell Premium"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [shell,aliases,fastfetch,motd,service-check]
# description: "Advanced shell: fastfetch MOTD, service status checks, power-user aliases (nsw, ntest, etc.)."
# path: "modules/00-core/07-shell-premium.nix"
# provides: [my.shell.premium]
# requires: [00-core]
# links:
#   module: modules/00-core/07-shell-premium.nix
# source: _meta/00-core/shell-premium.nix (NIXH-00-COR-029)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
let
  serviceStatusScript = pkgs.writeShellScriptBin "check-services" ''
    #!/usr/bin/env bash
    CRITICAL_SERVICES=("sshd:SSH" "caddy:Caddy" "tailscaled:Tailscale" "fail2ban:Fail2ban")
    echo -e "\n🔧 Service Status:\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    for entry in "''${CRITICAL_SERVICES[@]}"; do
      service="''${entry%%:*}"; label="''${entry##*:}"
      if systemctl is-active --quiet "$service"; then echo "  ✅ $label"; else echo "  ❌ $label (ERROR!)"; fi
    done
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  '';
in
{
  options.my.shell.premium.enable = lib.mkEnableOption "Advanced Shell Features (Fastfetch, Service Checks)";

  config = lib.mkIf config.my.shell.premium.enable {
    programs.bash.shellAliases = {
      nsw = "sudo nixos-rebuild switch";
      ntest = "sudo nixos-rebuild test";
      ndry = "sudo nixos-rebuild dry-run";
      nboot = "sudo nixos-rebuild boot";
      nup = "nix flake update";
      nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
      nopt = "sudo nix-store --optimise";
      ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      ncfg = "cd /etc/nixos";
      ngit = "cd /etc/nixos && git status -sb";
      nlog = "journalctl -xef";
      ls = "${pkgs.eza}/bin/eza --icons";
      ll = "${pkgs.eza}/bin/eza -la --icons --git";
      tree = "${pkgs.eza}/bin/eza --tree --icons";
      cat = "${pkgs.bat}/bin/bat --paging=never";
      top = "${pkgs.htop}/bin/htop";
      df = "${pkgs.duf}/bin/duf";
      du = "${pkgs.dust}/bin/dust";
      services = "${serviceStatusScript}/bin/check-services";
      ports = "sudo ss -tulpn";
      gs = "git status -sb";
      ga = "git add";
      gc = "git commit -m";
      gp = "git push";
      gl = "git log --oneline --graph --decorate --all -n 10";
    };

    environment.systemPackages = with pkgs; [
      bat eza ripgrep fd duf dust htop nix-tree nix-diff nixfmt-classic nix-output-monitor
      fastfetch micro git curl wget tree unzip file lsof ncdu serviceStatusScript
    ];
  };
}
