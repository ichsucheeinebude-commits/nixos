{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  nms = {
    id = "NIXH-00-COR-013";
    title = "Home Manager (SRE Profile)";
    description = "User-environment management with secure shell-secret loading.";
    layer = 00;
    nixpkgs.category = "tools/admin";
    capabilities = ["user/environment" "shell/hardening"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };
  user = config.my.configs.identity.user;
  envFile = config.my.secrets.files.sharedEnv;
in {
  options.my.meta.home_manager = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  imports = [inputs.home-manager.nixosModules.home-manager];

  config = {
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "hm-backup";
      users.${user} = {...}: {
        imports = [(./user-${user}-home.nix)];
        programs.bash.initExtra = ''
          if [ -f "${envFile}" ]; then set -a; source "${envFile}"; set +a; fi
        '';
        programs.bash.shellAliases = {godmode = "gemini --yolo --include-directories /etc/nixos,/home/moritz";};
      };
    };
  };
}
