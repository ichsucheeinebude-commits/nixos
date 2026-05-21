# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-021"
# title: "OliveTin"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [apps,automation,control-panel,olivetin,socket-activation]
# description: "Web-based control panel with Wake-on-Access (Socket Activation) and secure command pinning."
# path: "modules/60-apps/71-olivetin.nix"
# provides: [my.apps.olivetin]
# requires: [my.network.caddy, my.core.ports]
# links:
#   adr: docs/adr/ADR-71-olivetin.md
#   guide: docs/guides/71-olivetin.md
#   module: modules/60-apps/71-olivetin.nix
#   upstream: https://github.com/OliveTin/OliveTin
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# System-Administration über CLI ist effizient, aber nicht für alle Team-
# Mitglieder zugänglich. OliveTin bietet ein Web-UI mit vordefinierten,
# sicher gepinnten Shell-Befehlen.
#
# ### Entscheidung
#
# **OliveTin Pattern:**
# 1.  **Wake-on-Access** — Socket Activation: Service startet erst bei erster Anfrage.
# 2.  **Command Pinning** — Nur explizit definierte Befehle sind ausführbar.
# 3.  **Sudo Rules** — Minimal benötigte sudo-Rechte für den olivetin User.
# 4.  **Pre-configured Actions** — System Update, Secret Creation, Certificate Generation.
#
# ### SRE-Standards
#
# - Socket-Activation: wantedBy = sockets.target, service wantedBy = lib.mkForce [].
# - Sudo nur für nixos-rebuild und definierte Skripte (nicht ALL).
# - tmpfiles rule für Zertifikat-Landing-Zone.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  port = config.my.core.ports.olivetin or 1337;

  mtlsGenScript = "${config.my.core.scriptsDir or "/etc/nixos/modules/00-core/scripts"}/mtls-generator.sh";
in
{
  options.my.apps.olivetin = {
    enable = lib.mkEnableOption "OliveTin web-based control panel";
    port = lib.mkOption {
      type = lib.types.port;
      default = port;
      description = "Port for OliveTin service.";
    };
    actions = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          title = lib.mkOption { type = lib.types.str; description = "Button label."; };
          shell = lib.mkOption { type = lib.types.str; description = "Shell command to execute."; };
          icon = lib.mkOption { type = lib.types.str; default = "&#x1F6E0;"; description = "HTML entity icon."; };
          arguments = lib.mkOption {
            type = lib.types.listOf (lib.types.submodule {
              options = {
                name = lib.mkOption { type = lib.types.str; };
                type = lib.mkOption { type = lib.types.str; default = "ascii"; };
                title = lib.mkOption { type = lib.types.str; default = ""; };
              };
            });
            default = [];
            description = "Interactive arguments for the action.";
          };
        };
      });
      default = [];
      description = "Pre-configured actions (command pins).";
    };
  };

  config = lib.mkIf config.my.apps.olivetin.enable {
    services.olivetin = {
      enable = true;
      path = with pkgs; [
        bash openssl jq coreutils gnsed
        systemd nixos-rebuild nix-output-monitor
        curl sops
      ];
      settings = {
        ListenAddressSingleHTTPFrontend = "127.0.0.1:${toString config.my.apps.olivetin.port}";
        actions = config.my.apps.olivetin.actions;
      };
    };

    # ── Socket Activation (Wake-on-Access) ──
    systemd.sockets.olivetin = {
      description = "OliveTin Socket";
      wantedBy = [ "sockets.target" ];
      listenStreams = [ (toString config.my.apps.olivetin.port) ];
    };

    systemd.services.olivetin = {
      wantedBy = lib.mkForce [];
      requires = [ "olivetin.socket" ];
      after = [ "olivetin.socket" ];
    };

    # ── Minimal Sudo Rules ──
    security.sudo.extraRules = [
      {
        users = [ "olivetin" ];
        commands = [
          {
            command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
            options = [ "NOPASSWD" ];
          }
          {
            command = mtlsGenScript;
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];

    # ── Certificate Landing Zone ──
    systemd.tmpfiles.rules = [
      "d /var/www/landing-zone/certs 0755 caddy caddy -"
    ];
  };
}
