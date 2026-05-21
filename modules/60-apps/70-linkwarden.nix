# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-020"
# title: "Linkwarden"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [apps,bookmarks,linkwarden,archive,sandboxing]
# description: "Collaborative bookmark manager with automatic archiving and DynamicUser sandboxing."
# path: "modules/60-apps/70-linkwarden.nix"
# provides: [my.apps.linkwarden]
# requires: [my.network.caddy, my.core.ports]
# links:
#   adr: docs/adr/ADR-70-linkwarden.md
#   guide: docs/guides/70-linkwarden.md
#   module: modules/60-apps/70-linkwarden.nix
#   upstream: https://github.com/linkwarden/linkwarden
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Bookmarks sollen nicht im Browser verloren gehen. Linkwarden bietet
# kollaboratives Bookmark-Management mit automatischem Archiving — jede
# gespeicherte URL wird als Snapshot gespeichert.
#
# ### Entscheidung
#
# **Linkwarden Pattern:**
# 1.  **NixOS Service** — services.linkwarden.enable = true.
# 2.  **Caddy Integration** — Reverse Proxy mit SSO-Auth.
# 3.  **DynamicUser Sandboxing** — systemd DynamicUser = true, strict security.
# 4.  **SSO Integration** — import sso_auth in Caddy config.
#
# ### SRE-Standards
#
# - DynamicUser = true (kein fester User angelegt).
# - ProtectSystem = strict, ProtectHome = true.
# - SystemCallFilter = ["@system-service" "~@privileged"].
# - OOMScoreAdjust = 300 (kann bei Speicherknappheit gekillt werden).
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  port = config.my.core.ports.linkwarden or 3000;
  domain = config.my.core.identity.domain;
in
{
  options.my.apps.linkwarden = {
    enable = lib.mkEnableOption "Linkwarden collaborative bookmark manager";
    port = lib.mkOption {
      type = lib.types.port;
      default = port;
      description = "Port for Linkwarden service.";
    };
  };

  config = lib.mkIf config.my.apps.linkwarden.enable {
    services.linkwarden = {
      enable = true;
      environment = {
        NEXTAUTH_URL = "https://links.${domain}/api/v1/auth";
      };
    };

    # ── Caddy Reverse Proxy ──
    services.caddy.virtualHosts."links.${domain}" = {
      extraConfig = "import sso_auth\nreverse_proxy 127.0.0.1:${toString config.my.apps.linkwarden.port}";
    };

    # ── Systemd Sandboxing (DynamicUser) ──
    systemd.services.linkwarden = {
      serviceConfig = {
        DynamicUser = true;
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        SystemCallFilter = [ "@system-service" "~@privileged" ];
        OOMScoreAdjust = 300;
        StateDirectory = "linkwarden";
      };
    };
  };
}
