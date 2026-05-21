{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
  ];

  users.users."REPLACE_USER" = {
    isNormalUser  = true;
    description   = "REPLACE_USER";
    extraGroups   = [ "networkmanager" "wheel" ];
    shell         = pkgs.bash;
  };
}
