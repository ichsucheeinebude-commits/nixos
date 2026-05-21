# ---NIXMETA
# ---
# domain: user
# id: "NIXH-USER-MORITZ"
# title: "User: moritz (Home Manager)"
# type: user
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [user,moritz,home-manager,shell,aliases]
# description: "Home Manager config for moritz – shell aliases and personal packages."
# path: "users/moritz/home.nix"
# provides: []
# requires: []
# links:
#   module: users/moritz/home.nix
# ---
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:

{
  home.username      = "moritz";
  home.homeDirectory = "/home/moritz";

  # ── Personal Packages ────────────────────────────────────────────────
  home.packages = with pkgs; [
    htop git micro bat eza ripgrep fd nix-tree nix-diff nixfmt-rfc-style
    fastfetch duf dust nmap jq curl wget tree tmux fzf zoxide
  ];

  # ── Shell Aliases (from shell.nix) ────────────────────────────────────
  programs.bash.shellAliases = {
    # NixOS rebuild helpers
    nsw   = "sudo nixos-rebuild switch";
    ntest = "sudo nixos-rebuild test";
    ndry  = "sudo nixos-rebuild dry-run";
    nboot = "sudo nixos-rebuild boot";

    # Nix maintenance
    nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
    nopt   = "sudo nix-store --optimise";
    ngen   = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";

    # Config navigation
    ncfg   = "cd /etc/nixos";
    ngit   = "cd /etc/nixos && git status -sb";

    # System monitoring
    nlog  = "journalctl -xef";
    ports = "sudo ss -tulpn";
    top   = "${pkgs.htop}/bin/htop";

    # Better defaults
    ls   = "${pkgs.eza}/bin/eza --icons";
    ll   = "${pkgs.eza}/bin/eza -la --icons --git";
    tree = "${pkgs.eza}/bin/eza --tree --icons";
    cat  = "${pkgs.bat}/bin/bat --paging=never";
    less = "${pkgs.bat}/bin/bat";
    df   = "${pkgs.duf}/bin/duf";
    du   = "${pkgs.dust}/bin/dust";
  };

  programs.bash.shellInit = ''
    export HISTCONTROL=ignoredups:ignorespace
    export EDITOR='micro'
    export VISUAL='micro'
  '';

  programs.bash.completion.enable = true;

  # ── Git Config ───────────────────────────────────────────────────────
  programs.git = {
    enable = true;
    userName  = "moritz";
    userEmail = "moritz@m7c5.de";
    extraConfig = {
      pull.ff = "only";
      init.defaultBranch = "main";
    };
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
