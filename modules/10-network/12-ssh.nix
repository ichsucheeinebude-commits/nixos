# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-003"
# title: "SSH Server"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,ssh,openssh]
# description: "OpenSSH server configuration."
# path: "modules/10-network/12-ssh.nix"
# provides: [my.network.ssh]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/GUIDE-placeholder.md
#   module: modules/10-network/12-ssh.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:
{
  options.my.network.ssh = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable OpenSSH."; };
    port = lib.mkOption { type = lib.types.port; default = 22; description = "SSH listening port."; };
    passwordAuth = lib.mkOption { type = lib.types.bool; default = false; description = "Allow password authentication (forbidden by policy)."; };
    forbidDontPermitRootLogin = lib.mkOption { type = lib.types.bool; default = false; description = "When true, root login is permitted."; };
  };

  config = lib.mkIf config.my.network.ssh.enable {
    services.openssh = {
      enable = true;
      ports = [ config.my.network.ssh.port ];
      settings = {
        PasswordAuthentication = config.my.network.ssh.passwordAuth;
        PermitRootLogin = if config.my.network.ssh.forbidDontPermitRootLogin then "yes" else "no";
        KbdInteractiveAuthentication = false;
      };
    };
    # Expose port to firewall module
    my.core.ports.ssh = lib.mkDefault config.my.network.ssh.port;
  };
}

