{ config, pkgs, lib, ... }:

{
  home.username      = "moritz";
  home.homeDirectory = "/home/moritz";

  home.packages = with pkgs; [
    htop git
  ];

  programs.git = {
    enable  = true;
    userName  = "moritz";
    userEmail = "moritz@example.com";
  };

  programs.home-manager.enable = true;
  home.stateVersion = "24.11";
}
