{
  lib,
  config,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-032";
    title = "SSH (SRE Expert Edition)";
    description = "Hardened SSH daemon with connection protection, modern crypto and explicit legal banners.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = ["security/ssh" "network/hardening"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 3;
  };
  sshPort = config.my.ports.ssh;
  user = config.my.configs.identity.user;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  matchCidrs = lib.concatStringsSep "," (lanCidrs ++ tailnetCidrs);
in {
  options.my.meta.ssh = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    services.openssh = {
      enable = true;
      openFirewall = false;
      ports = lib.mkForce [22 sshPort];

      # ⚖️ LEGAL BANNER
      banner = ''
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
        UNAUTHORIZED ACCESS TO THIS SYSTEM IS STRICTLY PROHIBITED
        All activities are logged. SRE Cockpit v4.2 active.
        ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      '';

      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        AllowUsers = ["${user}"];
        LogLevel = "VERBOSE";
        LoginGraceTime = 20;
        MaxAuthTries = 3;
        ClientAliveInterval = 300;
        ClientAliveCountMax = 2;
        X11Forwarding = false; # 🛡️ Hardening: No X11 over SSH

        # 🏎️ MODERN CRYPTO (Curve25519 & ChaCha20)
        KexAlgorithms = [
          "curve25519-sha256"
          "curve25519-sha256@libssh.org"
          "sntrup761x25519-sha512@openssh.com"
        ];
        Ciphers = [
          "chacha20-poly1305@openssh.com"
          "aes256-gcm@openssh.com"
        ];
      };

      # 🌍 INTERNAL ACCESS POLICY
      extraConfig = ''
        Match Address 127.0.0.1,::1,${matchCidrs}
          AllowTcpForwarding yes
          GatewayPorts yes
      '';
    };

    # 🛡️ SYSTEMD HARDENING
    systemd.services.sshd = {
      stopIfChanged = false;
      serviceConfig = {
        Restart = "always";
        RestartSec = "5s";
        ProtectProc = "invisible";
        ProcSubset = "pid";
        PrivateTmp = true;
        ProtectSystem = "strict";
        ProtectHome = "read-only";
        CapabilityBoundingSet = [
          "CAP_CHOWN"
          "CAP_SETUID"
          "CAP_SETGID"
          "CAP_SYS_CHROOT"
          "CAP_AUDIT_WRITE"
          "CAP_NET_BIND_SERVICE"
        ];
      };
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:01c344dc17f10361ad8ed7045216eb8cbf3730ef91aab37c67cb4147acb85d8d
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

