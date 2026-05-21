# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-036"
# title: "TTY Info"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [tty,console,ip-info,observability]
# description: "Display IP addresses and SSH info on physical console (TTY1)."
# path: "modules/00-core/08-tty-info.nix"
# provides: [my.ttyInfo]
# requires: [00-core]
# links:
#   module: modules/00-core/08-tty-info.nix
# source: _meta/00-core/tty-info.nix (NIXH-00-COR-036)
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, ... }:
{
  options.my.ttyInfo.enable = lib.mkEnableOption "Display IP info on TTY1";

  config = lib.mkIf config.my.ttyInfo.enable {
    systemd.services.tty-ip-info = {
      description = "Display IP Address on TTY1";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        StandardOutput = "tty";
        TTYPath = "/dev/tty1";
      };
      script = ''
        sleep 2
        echo -e "\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\033[1;32m🌐 NIXHOME SYSTEM STATUS\033[0m"
        echo -e "\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m"
        echo -e "\n\033[1;34m📍 IPv4 Addresses:\033[0m"
        ${pkgs.iproute2}/bin/ip -4 -o addr show | ${pkgs.gnugrep}/bin/grep -v 'lo' | ${pkgs.gawk}/bin/awk '{print "   • " $2 ": " $4}' | ${pkgs.gnused}/bin/sed 's|/[0-9]*||'
        echo -e "\n\033[1;34m🔗 Local URLs:\033[0m"
        echo -e "   • http://nixhome.local"
        echo -e "   • http://$(hostname).local"
        echo -e "\n\033[1;33m🛠  SSH Access:\033[0m"
        echo -e "   ssh ${config.my.configs.identity.user}@$(hostname).local -p ${toString config.my.ports.ssh}"
        echo -e "\n\033[1;32m━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\033[0m\n"
      '';
    };
  };
}
