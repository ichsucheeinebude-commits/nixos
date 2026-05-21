{ config, pkgs, ... }:

{
  imports = [
    ./home.nix
  ];

  users.users."moritz" = {
    isNormalUser  = true;
    description   = "Moritz";
    extraGroups   = [ "networkmanager" "wheel" ];
    shell         = pkgs.bash;
  };
}
