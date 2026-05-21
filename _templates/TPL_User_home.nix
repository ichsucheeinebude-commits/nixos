{ config, pkgs, lib, ... }:

{
  home.username      = "REPLACE_USER";
  home.homeDirectory = "/home/REPLACE_USER";

  home.packages = with pkgs; [
    htop git
  ];

  programs.git = {
    enable    = true;
    userName  = "REPLACE_USER";
    userEmail = "REPLACE_USER@example.com";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
