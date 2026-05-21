# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-AMP-001"
# title: "AMP Gaming"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [amp, gaming]
# description: "AMP Gaming module."
# path: "modules/80-gaming/80-amp.nix"
# provides: [my.gaming.amp]
# requires: [30-storage/30-storage]
# links:
#   adr: docs/adr/ADR-80-amp.md
#   guide: docs/guides/80-amp.md
#   module: modules/80-gaming/80-amp.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, myLib, ... }:

let
  cfg = config.my.services.amp;
  # Call our FHS sandbox
  amp-fhs = pkgs.callPackage ../apps/_amp-fhs.nix {};
  
  # Helper to access project paths
  srePaths = config.my.configs.paths;
  domain = config.my.configs.identity.domain;
  
  # We use the FHS wrapper to run ampinstmgr
  # The actual binary for the daemon will be installed inside /var/lib/amp/instances/...
  # during the bootstrap phase.
in {
  options.my.services.amp = {
    enable = lib.mkEnableOption "AMP Game Server Panel";
    port = lib.mkOption {
      type = lib.types.port;
      default = config.my.ports.amp;
      description = "Internal port for AMP Web UI.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.amp = {
      description = "AMP Game Server Manager (Native FHS)";
      after = [ "network.target" "local-fs.target" ];
      wantedBy = [ "multi-user.target" ];
      
      serviceConfig = {
        ExecStart = "${amp-fhs}/bin/amp-fhs -c 'ampinstmgr startall'";
        User = "amp";
        Group = "amp";
        WorkingDirectory = "/var/lib/amp";
        Restart = "on-failure";
        RestartSec = "10s";
        
        # Hardening
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        
        # Paths
        ReadWritePaths = [ "/var/lib/amp" ];
        # AMP needs to be able to spawn game servers (forking, networking)
        PrivateNetwork = false;
        PrivateUsers = false; # Needed for game server management
        PrivateDevices = false; # Often needed for game servers
      };
    };

    users.users.amp = {
      isSystemUser = true;
      uid = config.my.users.registry.amp;
      group = "amp";
      home = "/var/lib/amp";
      createHome = true;
      shell = "${amp-fhs}/bin/amp-fhs"; # Allow sudo -u amp to enter FHS env
    };
    users.groups.amp = {};

    my.persistence.directories = [
      "/var/lib/amp"
    ];

    services.caddy.virtualHosts."amp.${domain}" = {
      extraConfig = ''
        import admin_auth
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/amp 0750 amp amp -"
    ];

    my.meta.amp = {
      id = "NIXH-SVC-AMP-001";
      title = "AMP Game Server Panel";
      layer = 60;
      audit.last_reviewed = "2026-05-17";
    };
  };
}
