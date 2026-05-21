# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-033"
# title: "GeoIP Database Auto-Update"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [security,geoip,nftables,firewall,auto-update]
# description: "Daily auto-update of nftables GeoIP and datacenter blocklists. Fetches country-specific IP ranges, datacenter blocks, and Tor exit nodes. Applies to live nftables sets with ntfy alerting on failure."
# path: "modules/20-security/33-geoip-update.nix"
# provides: [my.security.geoip]
# requires: []
# links:
#   module: modules/20-security/33-geoip-update.nix
# source: mynixos-v5/modules/security/geoip-update.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

let
  cfg = config.my.security.geoip;
  geoipDir = "/var/lib/geoip";

  # Datacenter / Hosting Blocklist URLs
  dcSources = [
    "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level1.netset"
    "https://raw.githubusercontent.com/firehol/blocklist-ipsets/master/firehol_level2.netset"
  ];
in
{
  # ── GeoIP Database Auto-Update ──
  # Fetches country-specific IP ranges, datacenter blocks, and Tor exit nodes.
  # Applies to live nftables sets daily.

  options.my.security.geoip = {
    enable = lib.mkEnableOption "GeoIP nftables set auto-update";
    allowedCountries = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "de" "at" "ch" "lt" ];
      description = "ISO 3166-1 alpha-2 country codes for allowed GeoIP ranges.";
    };
    updateInterval = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "Systemd OnCalendar schedule for GeoIP updates.";
    };
    ntfyAlertTopic = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Ntfy topic for alerting on update failures. Null to disable alerts.";
    };
    ntfyUrl = lib.mkOption {
      type = lib.types.str;
      default = "https://ntfy.sh";
      description = "Base URL for the ntfy server.";
    };
  };

  config = lib.mkIf cfg.enable {
    systemd.services.geoip-update = {
      description = "Update nftables GeoIP and Datacenter sets";
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];
      startAt = cfg.updateInterval;
      path = with pkgs; [ curl nftables gawk sed coreutils gnugrep ];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "update-geoip-data" ''
          set -euo pipefail

          WORKDIR=$(mktemp -d)
          trap 'rm -rf "$WORKDIR"' EXIT

          GEO_V4="$WORKDIR/geo_v4.txt"
          GEO_V6="$WORKDIR/geo_v6.txt"
          DC_BLOCK="$WORKDIR/dc_block.txt"
          TOR_V4="$WORKDIR/tor_v4.txt"
          TOR_V6="$WORKDIR/tor_v6.txt"

          touch "$GEO_V4" "$GEO_V6" "$DC_BLOCK" "$TOR_V4" "$TOR_V6"

          # 1. Fetch GeoIP (IPv4)
          for cc in ${lib.concatStringsSep " " cfg.allowedCountries}; do
            echo "Fetching GeoIP v4 for $cc..."
            ${pkgs.curl}/bin/curl -sSfL "https://www.ipdeny.com/ipblocks/data/aggregated/$cc-aggregated.zone" >> "$GEO_V4" \
              || echo "Warning: Failed to fetch v4 for $cc"
          done

          # 2. Fetch GeoIP (IPv6)
          for cc in ${lib.concatStringsSep " " cfg.allowedCountries}; do
            echo "Fetching GeoIP v6 for $cc..."
            ${pkgs.curl}/bin/curl -sSfL "https://www.ipdeny.com/ipv6/ipaddresses/blocks/$cc.zone" >> "$GEO_V6" \
              || echo "Warning: Failed to fetch v6 for $cc"
          done

          # 3. Fetch Datacenter Blocklists
          for url in ${lib.concatStringsSep " " (map builtins.toString dcSources)}; do
            echo "Fetching DC blocklist from $url..."
            ${pkgs.curl}/bin/curl -sSfL "$url" | ${pkgs.gnugrep}/bin/grep -v "^#" >> "$DC_BLOCK" \
              || echo "Warning: Failed to fetch DC list from $url"
          done

          # 4. Fetch Tor Exit Nodes
          echo "Fetching Tor exit nodes..."
          TOR_DATA=$(${pkgs.curl}/bin/curl -sSfL "https://check.torproject.org/exit-addresses" || echo "")
          if [ -n "$TOR_DATA" ]; then
            echo "$TOR_DATA" | ${pkgs.gnugrep}/bin/grep "ExitAddress" \
              | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.gnugrep}/bin/grep -v ":" > "$TOR_V4" || true
            echo "$TOR_DATA" | ${pkgs.gnugrep}/bin/grep "ExitAddress" \
              | ${pkgs.gawk}/bin/awk '{print $2}' | ${pkgs.gnugrep}/bin/grep ":" > "$TOR_V6" || true
          fi

          # 5. Post-processing & Validation
          sort -u "$GEO_V4" | ${pkgs.gnugrep}/bin/grep -E "^([0-9]{1,3}\.){3}[0-9]{1,3}(/[0-9]+)?$" > "$GEO_V4.tmp" || true
          mv "$GEO_V4.tmp" "$GEO_V4"

          sort -u "$GEO_V6" | ${pkgs.gnugrep}/bin/grep ":" > "$GEO_V6.tmp" || true
          mv "$GEO_V6.tmp" "$GEO_V6"

          # 6. Atomic Update
          mkdir -p ${geoipDir}
          cp "$GEO_V4" "${geoipDir}/geo_allowed_v4.zone"
          cp "$GEO_V6" "${geoipDir}/geo_allowed_v6.zone"
          cp "$DC_BLOCK" "${geoipDir}/dc_blocked.zone"
          cp "$TOR_V4" "${geoipDir}/tor_exit_v4.zone"
          cp "$TOR_V6" "${geoipDir}/tor_exit_v6.zone"

          # 7. Apply to nftables
          NFT_FILE="$WORKDIR/apply.nft"
          {
            echo "table inet filter {"
            echo "  set geo_allowed {"
            echo "    type ipv4_addr; flags interval;"
            GEO_V4_ELEMS=$(${pkgs.coreutils}/bin/tr '\n' ',' < "$GEO_V4" | ${pkgs.gnused}/bin/sed 's/,$//' || true)
            [ -n "$GEO_V4_ELEMS" ] && echo "    elements = { $GEO_V4_ELEMS }"
            echo "  }"
            echo "  set geo_allowed_v6 {"
            echo "    type ipv6_addr; flags interval;"
            GEO_V6_ELEMS=$(${pkgs.coreutils}/bin/tr '\n' ',' < "$GEO_V6" | ${pkgs.gnused}/bin/sed 's/,$//' || true)
            [ -n "$GEO_V6_ELEMS" ] && echo "    elements = { $GEO_V6_ELEMS }"
            echo "  }"
            echo "  set dc_blocked {"
            echo "    type ipv4_addr; flags interval;"
            DC_V4_ELEMS=$(${pkgs.gnugrep}/bin/grep -v ":" "$DC_BLOCK" | ${pkgs.coreutils}/bin/tr '\n' ',' | ${pkgs.gnused}/bin/sed 's/,$//' || true)
            [ -n "$DC_V4_ELEMS" ] && echo "    elements = { $DC_V4_ELEMS }"
            echo "  }"
            echo "  set dc_blocked_v6 {"
            echo "    type ipv6_addr; flags interval;"
            DC_V6_ELEMS=$(${pkgs.gnugrep}/bin/grep ":" "$DC_BLOCK" | ${pkgs.coreutils}/bin/tr '\n' ',' | ${pkgs.gnused}/bin/sed 's/,$//' | ${pkgs.gnused}/bin/sed 's/^,//' || true)
            [ -n "$DC_V6_ELEMS" ] && echo "    elements = { $DC_V6_ELEMS }"
            echo "  }"
            echo "  set tor_exit_nodes {"
            echo "    type ipv4_addr; flags interval;"
            TOR_V4_ELEMS=$(${pkgs.coreutils}/bin/tr '\n' ',' < "$TOR_V4" | ${pkgs.gnused}/bin/sed 's/,$//' || true)
            [ -n "$TOR_V4_ELEMS" ] && echo "    elements = { $TOR_V4_ELEMS }"
            echo "  }"
            echo "  set tor_exit_nodes_v6 {"
            echo "    type ipv6_addr; flags interval;"
            TOR_V6_ELEMS=$(${pkgs.coreutils}/bin/tr '\n' ',' < "$TOR_V6" | ${pkgs.gnused}/bin/sed 's/,$//' || true)
            [ -n "$TOR_V6_ELEMS" ] && echo "    elements = { $TOR_V6_ELEMS }"
            echo "  }"
            echo "}"
          } > "$NFT_FILE"

          if ${pkgs.nftables}/bin/nft -f "$NFT_FILE"; then
            echo "✅ nftables sets updated successfully."
          else
            echo "❌ Failed to apply nftables update."
            ${lib.optionalString (cfg.ntfyAlertTopic != null) ''
              ${pkgs.curl}/bin/curl -d "nftables GeoIP update failed: malformed ruleset" "${cfg.ntfyUrl}/${cfg.ntfyAlertTopic}"
            ''}
            exit 1
          fi
        '';
        ProtectSystem = "strict";
        ReadWritePaths = [ geoipDir ];
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${geoipDir} 0750 root root -"
    ];
  };
}
