# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-FBT-001"
# title: "Forbidden Tech Policy"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [policy, forbidden]
# description: "Forbidden Tech Policy module."
# path: "modules/90-policy/90-forbidden-tech.nix"
# provides: [my.policy.forbidden]
# requires: []
# links:
#   adr: docs/adr/ADR-90-forbidden-tech.md
#   guide: docs/guides/90-forbidden-tech.md
#   module: modules/90-policy/90-forbidden-tech.nix
# ---
# ---ENDNIXMETA
{ config, lib, ... }:

let
  inherit (lib) mkOption types;

  forbiddenReasons = {
    secureBoot = "Secure Boot ist zu riskant. Fehler führen zu permanentem Lockout.";
    tailscale   = "Tailscale verursacht DNS-Probleme und schafft ungewollte Abhängigkeiten.";
    docker      = "Docker widerspricht dem NixOS-Prinzip. Native systemd-Services sind Pflicht.";
    mTLS-Admin  = "mTLS für Admin ist zu komplex. Chicken-and-Egg-Problem beim Erstzugriff.";
    lanzaboote  = "Lanzaboote wurde durch schlichtes systemd-boot ersetzt.";
    oliveTin    = "OliveTin hat Shell-Injection-Risiken. Wurde durch systemd-Oneshot-Units ersetzt.";
    fapolicyd   = "fapolicyd wurde nicht weiter verfolgt und wird nicht eingesetzt.";
    iptables    = "iptables ist veraltet. Ausschließlich nftables wird verwendet.";
    cron        = "cron ist veraltet. Ausschließlich systemd-Timer werden verwendet.";
    passwords   = "SSH-Passwort-Authentifizierung ist verboten. Nur hardware-gebundene Keys.";
    dockerSock  = "Der Zugriff auf docker.sock ist gleichbedeutend mit Root-Zugriff.";
    sftpgo      = "SFTPGo ist verboten. Dateizugriff erfolgt ausschließlich via FileBrowser oder SSH/SFTP.";
  };

in {
  options.my.policy.forbidden = {
    secureBoot = mkOption { type = types.bool; default = false; };
    tailscale   = mkOption { type = types.bool; default = false; };
    docker      = mkOption { type = types.bool; default = false; };
    mTLS-Admin  = mkOption { type = types.bool; default = false; };
    lanzaboote  = mkOption { type = types.bool; default = false; };
    oliveTin    = mkOption { type = types.bool; default = false; };
    fapolicyd   = mkOption { type = types.bool; default = false; };
    iptables    = mkOption { type = types.bool; default = false; };
    cron        = mkOption { type = types.bool; default = false; };
    passwords   = mkOption { type = types.bool; default = false; };
    dockerSock  = mkOption { type = types.bool; default = false; };
    sftpgo      = mkOption { type = types.bool; default = false; };
  };

  config = {
    # =========================================================================
    # =========================================================================
    assertions = [
      {
        assertion = !(config.boot.lanzaboote.enable or false);
        message = "❌ [POL-001] Forbidden Technology Detected: Lanzaboote. ${forbiddenReasons.secureBoot}";
      }
      {
        assertion = !(config.services.tailscale.enable or false);
        message = "❌ [POL-002] Forbidden Technology Detected: Tailscale. ${forbiddenReasons.tailscale}";
      }
      {
        assertion = !(config.virtualisation.docker.enable or false);
        message = "❌ [POL-003] Forbidden Technology Detected: Docker. ${forbiddenReasons.docker}";
      }
      {
        assertion = config.networking.nftables.enable;
        message = "❌ [POL-004] Forbidden Technology Detected: Legacy iptables. Please enable nftables. ${forbiddenReasons.iptables}";
      }
      {
        assertion = !(config.services.cron.enable or false);
        message = "❌ [POL-005] Forbidden Technology Detected: Cron. Please use systemd timers. ${forbiddenReasons.cron}";
      }
      {
        assertion = !(config.services.openssh.settings.PasswordAuthentication or true);
        message = "❌ [POL-006] Forbidden Policy Detected: SSH Password Auth enabled. ${forbiddenReasons.passwords}";
      }
      {
        assertion = !(config.services.sftpgo.enable or false);
        message = "❌ [POL-007] Forbidden Technology Detected: SFTPGo. ${forbiddenReasons.sftpgo}";
      }
    ];
  };
}
