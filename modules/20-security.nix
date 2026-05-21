# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-20-SEC-001",
#   "title": "Security Hardening",
#   "layer": 20,
#   "category": "security",
#   "lastReviewed": "YYYY-MM-DD",
#   "reviewedBy": "moritz",
#   "status": "draft",
#   "complexity": 3,
#   "description": "Hardened SSH daemon with modern crypto, nftables with LAN/Tailscale CIDR rules",
#   "tags": ["ssh", "firewall", "nftables", "hardening", "security"]
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

# ── Security Module ───────────────────────────────────────────────────
# SSH Hardening + nftables Firewall

let
  core       = config.my.core;
  sshPort    = core.ports.ssh or 53844;
  user       = core.identity.user or "moritz";
  lanCidrs   = core.network.lanCidrs or [ "192.168.0.0/16" "10.0.0.0/8" "172.16.0.0/12" ];
  tailnetCidrs = core.network.tailnetCidrs or [ "100.64.0.0/10" ];
  matchCidrs = lib.concatStringsSep "," (lanCidrs ++ tailnetCidrs);
in {

  # ── SSH Hardening (anchor: ssh-hardening) ───────────────────────────
  services.openssh = {
    enable        = true;
    openFirewall  = false;
    ports         = lib.mkForce [ 22 sshPort ];

    banner = ''
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
      UNAUTHORIZED ACCESS TO THIS SYSTEM IS STRICTLY PROHIBITED
      All activities are logged.
      ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
    '';

    settings = {
      PermitRootLogin              = "no";
      PasswordAuthentication       = false;
      KbdInteractiveAuthentication = false;
      AllowUsers                   = [ user ];
      LogLevel                     = "VERBOSE";
      LoginGraceTime               = 20;
      MaxAuthTries                 = 3;
      ClientAliveInterval          = 300;
      ClientAliveCountMax          = 2;
      X11Forwarding                = false;

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

    extraConfig = ''
      Match Address 127.0.0.1,::1,${matchCidrs}
        AllowTcpForwarding yes
        GatewayPorts yes
    '';
  };

  # SSH systemd hardening
  systemd.services.sshd = {
    stopIfChanged = false;
    serviceConfig = {
      Restart    = "always";
      RestartSec = "5s";
      ProtectProc        = "invisible";
      ProcSubset         = "pid";
      PrivateTmp         = true;
      ProtectSystem      = "strict";
      ProtectHome        = "read-only";
      CapabilityBoundingSet = [
        "CAP_CHOWN" "CAP_SETUID" "CAP_SETGID"
        "CAP_SYS_CHROOT" "CAP_AUDIT_WRITE" "CAP_NET_BIND_SERVICE"
      ];
    };
  };

  # ── Firewall (anchor: firewall) ────────────────────────────────────
  networking.firewall = {
    enable                = !core.bastelmodus;
    trustedInterfaces     = [ "tailscale0" "lo" ];
    allowedTCPPorts       = [ 443 80 22 sshPort ];
    logRefusedConnections = false;

    extraInputRules = ''
      ip saddr { ${lib.concatStringsSep ", " lanCidrs}, ${lib.concatStringsSep ", " tailnetCidrs} } tcp dport 53 accept
      ip saddr { ${lib.concatStringsSep ", " lanCidrs}, ${lib.concatStringsSep ", " tailnetCidrs} } udp dport 53 accept
      ip saddr { ${lib.concatStringsSep ", " lanCidrs} } udp dport 5353 accept
      ip protocol icmp accept
    '';
  };

  # ── Kernel Hardening ───────────────────────────────────────────────
  security.apparmor.enable = true;
  security.lockKernelModules = true;
}
