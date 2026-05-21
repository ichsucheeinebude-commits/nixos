{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
  ];

  users.users."freund" = {
    isNormalUser  = true;
    description   = "Freund";
    extraGroups   = [ "networkmanager" ];
    shell         = pkgs.bash;
  };
}
