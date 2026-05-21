# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-031"
# title: "Security Stats Collector"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [security,nftables,stats,metrics]
# description: "Collects nftables set metrics (geo allowed, datacenter blocked, Tor exit nodes) into a JSON stats file. Runs hourly."
# path: "modules/20-security/31-security-stats.nix"
# provides: [my.security.stats]
# requires: [00-core]
# links:
#   module: modules/20-security/31-security-stats.nix
# source: mynixos-v5/modules/security/security-stats.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  statsFile = "/var/lib/geoip/stats.json";
in
{
  # ── Security Stats Collector ──
  # Collects nftables set metrics into JSON for monitoring.

  options.my.security.stats = {
    enable = lib.mkEnableOption "Security stats collection";
  };

  config = lib.mkIf config.my.security.stats.enable {
    systemd.services.collect-security-stats = {
      description = "Collect nftables and security metrics";
      startAt = "hourly";
      path = [ pkgs.jq ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "collect-security-stats" ''
          set -euo pipefail

          # Helper to count elements in nftables sets
          count_elements() {
            local set_name=$1
            ${pkgs.nftables}/bin/nft -j list set inet filter "$set_name" 2>/dev/null \
              | ${pkgs.jq}/bin/jq '.nftables[].set.elem | length' 2>/dev/null || echo "0"
          }

          GEO_COUNT=$(count_elements "geo_allowed")
          DC_COUNT=$(count_elements "dc_blocked")
          TOR_COUNT=$(count_elements "tor_exit_nodes")

          TIMESTAMP=$(${pkgs.coreutils}/bin/date -u +"%Y-%m-%dT%H:%M:%SZ")

          cat <<EOF > ${statsFile}.tmp
          {
            "last_updated": "$TIMESTAMP",
            "sets": {
              "geo_allowed": $GEO_COUNT,
              "dc_blocked": $DC_COUNT,
              "tor_exit_nodes": $TOR_COUNT
            }
          }
          EOF

          mv ${statsFile}.tmp ${statsFile}
          echo "Security stats updated at $TIMESTAMP"
        '';
        ProtectSystem = "strict";
        ReadWritePaths = [ "/var/lib/geoip" ];
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d /var/lib/geoip 0750 root root -"
    ];
  };
}
