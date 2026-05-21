# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-040"
# title: "Service Helpers Library"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-21
# tags: [core,library,abstraction,service,factory,hardening]
# description: "Central library providing mkService abstraction — one-call service definition with systemd hardening, Caddy reverse proxy, and SSO integration."
# path: "modules/00-core/12-lib-helpers.nix"
# provides: [my.lib.mkService]
# requires: [my.network.dnsMap, my.network.caddy]
# links:
#   adr: pending
#   guide: pending
#   module: modules/00-core/12-lib-helpers.nix
#   upstream: https://nixos.org/manual/nixos/stable/#opt-systemd.services
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Jeder Service benötigt: systemd-Definition, Hardening, Caddy Reverse Proxy,
# SSO-Integration, Port-Konfiguration. Das manuell für jeden Service zu
# schreiben erzeugt viel Boilerplate und Inkonsistenzen.
#
# ### Entscheidung
#
# **mkService Factory Pattern:**
# 1.  **Ein Aufruf** — Alle Service-Aspekte in einem Funktionsaufruf.
# 2.  **Automatisches Hardening** — ProtectSystem, PrivateTmp, NoNewPrivileges.
# 3.  **Caddy Integration** — Reverse Proxy + SSO automatisch konfiguriert.
# 4.  **Network Namespace Support** — Optionale VPN-Isolation.
# 5.  **DNS Map Lookup** — Hostname aus zentralem DNS-Mapping.
#
# ### SRE-Standards
#
# - mkService erzeugt systemd.services.<name> UND services.caddy.virtualHosts.
# - Trusted Network: 127.0.0.1, Tailscale CGNAT, LAN CIDRs.
# - SSO ist Standard (import sso_auth in Caddy config).
# - Network Namespace: optional für VPN-confinement.
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  dnsMap = config.my.network.dnsMap.mapping or {};
  baseDomain = config.my.network.dnsMap.baseDomain or "";
  lanCidrs = config.my.core.network.lanCidrs or [];

  # ── mkService Factory ──
  #
  # Usage:
  #   my.lib.mkService {
  #     name = "myservice";
  #     port = 8080;
  #     description = "My awesome service";
  #     readWritePaths = [ "/var/lib/myservice" ];
  #     allowNetwork = true;
  #     netns = null;  # or "my-vault" for network namespace isolation
  #   }
  #
  mkService = {
    name,
    port ? null,
    useSSO ? true,
    description ? "Managed Service",
    readWritePaths ? [],
    allowNetwork ? true,
    netns ? null,
    extraCaddyConfig ? "",
    extraServiceConfig ? {},
  }:
  let
    finalPort = if port != null then port
      else throw "mkService: port must be provided for ${name}";

    host = if dnsMap ? ${name} then dnsMap.${name}
      else "${name}.${baseDomain}";

    targetHost = if netns != null then "10.200.1.2"
      else "127.0.0.1";

    target = "http://${targetHost}:${toString finalPort}";

    trustedNetworks = lib.concatStringsSep " " ([ "127.0.0.1" "100.64.0.0/10" ] ++ lanCidrs);
  in {
    # ── Systemd Service ──
    systemd.services."${name}" = {
      serviceConfig = {
        Description = lib.mkDefault description;
        ProtectSystem = lib.mkDefault "strict";
        ProtectHome = lib.mkDefault true;
        PrivateTmp = lib.mkDefault true;
        PrivateDevices = lib.mkDefault true;
        NoNewPrivileges = lib.mkDefault true;
        Restart = lib.mkDefault "always";
        ReadWritePaths = lib.mkDefault readWritePaths;
        NetworkNamespacePath = lib.mkIf (netns != null) "/run/netns/${netns}";
        RestrictAddressFamilies = lib.mkIf allowNetwork (lib.mkDefault [ "AF_INET" "AF_INET6" "AF_UNIX" ]);
      } // extraServiceConfig;
    };

    # ── Caddy Reverse Proxy ──
    services.caddy.virtualHosts."${host}" = {
      extraConfig = ''
        @trusted_network remote_ip ${trustedNetworks}
        handle @trusted_network {
          reverse_proxy ${target}
        }
        ${lib.optionalString useSSO "import sso_auth"}
        reverse_proxy ${target}
        ${extraCaddyConfig}
      '';
    };
  };
in
{
  options.my.lib = {
    mkService = lib.mkOption {
      type = lib.types.functionTo lib.types.attrs;
      default = mkService;
      readOnly = true;
      description = "Factory function for creating hardened service definitions.";
    };
  };
}
