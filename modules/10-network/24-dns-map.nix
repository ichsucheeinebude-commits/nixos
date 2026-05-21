# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-NET-014"
# title: "DNS Map"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [network,dns,subdomain,services,mapping]
# description: "Central DNS subdomain mapping for all services. Provides consistent hostname resolution."
# path: "modules/10-network/24-dns-map.nix"
# provides: [my.network.dnsMap]
# requires: [my.core.identity]
# links:
#   adr: docs/adr/ADR-24-dns-map.md
#   guide: docs/guides/24-dns-map.md
#   module: modules/10-network/24-dns-map.nix
#   upstream: https://nixos.org/manual/nixos/stable/#opt-networking.hosts
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Jeder Service braucht einen Hostnamen. Statt diese manuell zu verwalten,
# wird ein zentrales DNS-Mapping verwendet, das automatisch Subdomains
# für alle Services generiert.
#
# ### Entscheidung
#
# **DNS Map Pattern:**
# 1.  **Subdomain-Struktur** — `<service>.<subdomain>.<domain>` (z.B. jellyfin.nix.m7c5.de).
# 2.  **Zentrale Map** — Alle Service-Hostnames an einem Ort.
# 3.  **Override-fähig** — Spezifische Services können eigene Hostnames setzen.
#
# ### SRE-Standards
#
# - Format: `<service>.<subdomain>.<domain>`
# - Subdomain standard: "nix"
# - Map ist ein AttrSet, erweiterbar pro Service.
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  domain = config.my.core.identity.domain;
  subdomain = config.my.core.identity.subdomain or "nix";
  baseDomain = "${subdomain}.${domain}";
in
{
  options.my.network.dnsMap = {
    useSubdomain = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Whether to use a subdomain prefix for service hostnames.";
    };
    baseDomain = lib.mkOption {
      type = lib.types.str;
      default = baseDomain;
      description = "Base domain for service hostnames.";
    };
    mapping = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        auth       = "auth.${baseDomain}";
        dashboard  = "dash.${baseDomain}";
        ddns       = "nix-ddns.${baseDomain}";
        dns        = "dns.${baseDomain}";
        filebrowser = "filebrowser.${baseDomain}";
        homeassistant = "home.${baseDomain}";
        jellyfin   = "jellyfin.${baseDomain}";
        matrix     = "matrix.${baseDomain}";
        miniflux   = "miniflux.${baseDomain}";
        monica     = "monica.${baseDomain}";
        n8n        = "n8n.${baseDomain}";
        netdata    = "netdata.${baseDomain}";
        olivetin   = "olivetin.${baseDomain}";
        paperless  = "paperless.${baseDomain}";
        readeck    = "readeck.${baseDomain}";
        scrutiny   = "scrutiny.${baseDomain}";
        status     = "status.${baseDomain}";
        vault      = "vault.${baseDomain}";
      };
      description = "Service name to hostname mapping.";
    };
  };

  config = lib.mkIf config.my.network.dnsMap.useSubdomain {
    # DNS entries for local resolution
    networking.hosts = lib.mkMerge (lib.mapAttrsToList (name: hostname: {
      "127.0.0.1" = [ hostname ];
    }) config.my.network.dnsMap.mapping);
  };
}
