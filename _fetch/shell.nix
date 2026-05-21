{ config, lib, pkgs, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-030";
    title = "Shell";
    description = "Standardized Bash environment with productivity tools and basic maintenance aliases.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "shell/bash" "tools/productivity" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };

  user = config.my.configs.identity.user;
in
{
  options.my.meta.shell = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for shell module";
  };

  config = lib.mkIf (user == "moritz") {
    programs.bash.shellAliases = {
      nsw = "sudo nixos-rebuild switch"; ntest = "sudo nixos-rebuild test"; ndry = "sudo nixos-rebuild dry-run"; nboot = "sudo nixos-rebuild boot";
      nclean = "sudo nix-env -p /nix/var/nix/profiles/system --delete-generations +5 && sudo nix-store --gc";
      nopt = "sudo nix-store --optimise"; ngen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
      ncfg = "cd /etc/nixos"; ngit = "cd /etc/nixos && git status -sb"; nlog = "journalctl -xef";
      ls = "${pkgs.eza}/bin/eza --icons"; ll = "${pkgs.eza}/bin/eza -la --icons --git"; tree = "${pkgs.eza}/bin/eza --tree --icons";
      cat = "${pkgs.bat}/bin/bat --paging=never"; less = "${pkgs.bat}/bin/bat"; top = "${pkgs.htop}/bin/htop";
      df = "${pkgs.duf}/bin/duf"; du = "${pkgs.dust}/bin/dust"; ports = "sudo ss -tulpn";
    };
    
    programs.bash.completion.enable = true;
    environment.systemPackages = with pkgs; [ bat eza ripgrep fd nix-tree nix-diff nixfmt fastfetch duf dust htop ];
    programs.git = { enable = true; config = { user.name = "Moritz Baumeister"; user.email = config.my.configs.identity.email; pull.ff = "only"; init.defaultBranch = "main"; }; };
    programs.bash.shellInit = "export HISTCONTROL=ignoredups:ignorespace\nexport EDITOR='micro'\nexport VISUAL='micro'";
  };
}
