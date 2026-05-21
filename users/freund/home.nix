{ config, pkgs, lib, ... }:

{
  home.username      = "freund";
  home.homeDirectory = "/home/freund";

  home.packages = with pkgs; [
    htop git
  ];

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
