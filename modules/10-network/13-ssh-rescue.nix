# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-004"
# title: "SSH Rescue"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,ssh,rescue]
# description: "Secondary SSH service for emergency access."
# path: "modules/10-network/13-ssh-rescue.nix"
# provides: [my.network.sshRescue]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/GUIDE-placeholder.md
#   module: modules/10-network/13-ssh-rescue.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.sshRescue = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable rescue SSH on port 2222."; };
    port = lib.mkOption { type = lib.types.port; default = 2222; description = "Rescue SSH port."; };
    authorizedKeys = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Rescue SSH keys."; };
  };

  config = lib.mkIf config.my.network.sshRescue.enable {
    systemd.services."sshd-rescue" = {
      description = "Rescue SSH Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${config.services.openssh.package}/bin/sshd -D -f /etc/ssh/sshd_config_rescue";
        Restart = "on-failure";
      };
    };
    environment.etc."ssh/sshd_config_rescue".text = 
      Port ${toString config.my.network.sshRescue.port}
      PermitRootLogin no
      PasswordAuthentication no
      PubkeyAuthentication yes
    ;
  };
}

