# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-060-GAM-AMP-001",
#   "title": "AMP Game Server Panel",
#   "layer": 60,
#   "category": "services/gaming",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["gaming", "amp", "fhs", "hardened"],
#   "description": "Native NixOS integration of AMP Game Server Panel using buildFHSEnv."
# }
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
    # 📝 1. SYSTEMD SERVICE (anchor: amp-service)
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

    # 👤 2. AMP SYSTEM USER
    users.users.amp = {
      isSystemUser = true;
      uid = config.my.users.registry.amp;
      group = "amp";
      home = "/var/lib/amp";
      createHome = true;
      shell = "${amp-fhs}/bin/amp-fhs"; # Allow sudo -u amp to enter FHS env
    };
    users.groups.amp = {};

    # 💾 3. PERSISTENCE
    my.persistence.directories = [
      "/var/lib/amp"
    ];

    # 🌐 4. CADDY ADMIN VHOST
    services.caddy.virtualHosts."amp.${domain}" = {
      extraConfig = ''
        import admin_auth
        reverse_proxy 127.0.0.1:${toString cfg.port}
      '';
    };

    # 📂 5. TMPFILES
    systemd.tmpfiles.rules = [
      "d /var/lib/amp 0750 amp amp -"
    ];

    # 📊 6. TRACEABILITY
    my.meta.amp = {
      id = "NIXH-SVC-AMP-001";
      title = "AMP Game Server Panel";
      layer = 60;
      audit.last_reviewed = "2026-05-17";
    };
  };
}
