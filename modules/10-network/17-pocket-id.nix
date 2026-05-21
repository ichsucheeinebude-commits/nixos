# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-007"
# title: "PocketID Identity Provider"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [network,identity,oidc,passkey,webauthn,sso]
# description: "PocketID OIDC provider with passkey-only authentication from KB identity specification."
# path: "modules/10-network/17-pocket-id.nix"
# provides: [my.network.pocket-id]
# requires: [00-core, 30-storage]
# links:
#   adr: docs/adr/ADR-17-pocket-id.md
#   guide: docs/guides/17-pocket-id.md
#   module: modules/10-network/17-pocket-id.nix
# source: services/identity-pocketid-v4.2.md
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  cfg = config.my.network.pocket-id;
in
{
  options.my.network.pocket-id = {
    enable = lib.mkEnableOption "PocketID OIDC identity provider with passkey authentication";

    # ── Network ──
    domain = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Public domain (e.g., https://auth.m7c5.de)";
    };
    listenPort = lib.mkOption {
      type = lib.types.port;
      default = 8080;
      description = "Port for PocketID web interface.";
    };
    listenIp = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "IP address to listen on.";
    };

    # ── OIDC ──
    oidcIssuer = lib.mkOption {
      type = lib.types.str;
      default = "self";
      description = "OIDC issuer identifier.";
    };
    sessionDuration = lib.mkOption {
      type = lib.types.str;
      default = "24h";
      description = "Session duration (e.g., 24h, 7d).";
    };
    allowedRedirectUris = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Allowed OIDC redirect URIs for clients.";
    };

    # ── Passkey/WebAuthn ──
    rpId = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Relying Party ID for WebAuthn (usually the domain).";
    };
    rpName = lib.mkOption {
      type = lib.types.str;
      default = "PocketID";
      description = "Relying Party display name.";
    };
    attestation = lib.mkOption {
      type = lib.types.enum [ "none" "direct" "indirect" ];
      default = "direct";
      description = "WebAuthn attestation conveyance preference.";
    };
    userVerification = lib.mkOption {
      type = lib.types.enum [ "required" "preferred" "discouraged" ];
      default = "preferred";
      description = "User verification requirement for passkeys.";
    };

    # ── Admin ──
    adminUsers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "List of admin user emails.";
    };
    publicRegistration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Allow public user registration.";
    };

    # ── Database ──
    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/pocket-id";
      description = "Data directory for PocketID database.";
    };

    # ── Client Apps ──
    clientApps = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; description = "App name."; };
          clientId = lib.mkOption { type = lib.types.str; description = "OIDC client ID."; };
          clientSecretFile = lib.mkOption {
            type = lib.types.nullOr lib.types.str;
            default = null;
            description = "Path to file containing client secret (via SOPS).";
          };
          redirectUris = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [];
            description = "Allowed redirect URIs for this app.";
          };
          scopes = lib.mkOption {
            type = lib.types.listOf lib.types.str;
            default = [ "openid" "email" "profile" ];
            description = "Allowed OAuth scopes.";
          };
        };
      });
      default = {};
      description = "OIDC client applications (e.g., Jellyfin, Vaultwarden).";
    };
  };

  config = lib.mkIf cfg.enable {
    # PocketID service (using the nixpkgs module if available, otherwise custom)
    services.pocket-id = {
      enable = true;
      port = cfg.listenPort;
      settings = {
        PUBLIC_URL = lib.mkIf (cfg.domain != null) cfg.domain;
        RP_ID = lib.mkIf (cfg.rpId != null) cfg.rpId;
        RP_NAME = cfg.rpName;
        SESSION_DURATION = cfg.sessionDuration;
        ATTESTATION = cfg.attestation;
        USER_VERIFICATION = cfg.userVerification;
        PUBLIC_REGISTRATION = if cfg.publicRegistration then "true" else "false";
      };
    };

    # ── Systemd Hardening ──
    systemd.services.pocket-id.serviceConfig = {
      ProtectSystem = "strict";
      ProtectHome = true;
      NoNewPrivileges = true;
      PrivateTmp = true;
      ReadWritePaths = [ cfg.dataDir ];
    };

    # ── Assertions ──
    assertions = [
      {
        assertion = cfg.domain != null -> cfg.rpId != null;
        message = "If a domain is configured, rpId must also be set for WebAuthn.";
      }
    ];
  };
}
