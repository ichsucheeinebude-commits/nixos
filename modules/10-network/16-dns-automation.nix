# ---NIXMETA
# ---
# domain: 10
# id: "NIXH-10-DNS-001"
# title: "DNS Automation"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [dns, cloudflare]
# description: "DNS Automation module."
# path: "modules/10-network/16-dns-automation.nix"
# provides: [my.network.dns_auto]
# requires: [10-network/14-blocky]
# links:
#   adr: docs/adr/ADR-10-dns-automation.md
#   guide: docs/guides/10-dns-automation.md
#   module: modules/10-network/16-dns-automation.nix
# ---
# ---ENDNIXMETA
{ config, pkgs, lib, ... }:
let
 
 runtimeDnsMap = "/var/lib/nixhome/dns-map-runtime.json";
 domain = config.my.configs.identity.domain;
 cfTokenFile = config.sops.secrets.cloudflare_token.path;
in
{


 config = lib.mkIf config.my.services.dnsAutomation.enable {
 systemd.services.dns-guard = {
 description = "Check Cloudflare for DNS conflicts";
 after = [ "network-online.target" "sops-install-secrets.service" ];
 requires = [ "network-online.target" ];
 serviceConfig = {
   Type = "oneshot";
   StateDirectory = "nixhome";
   ProtectSystem = "strict";
   ProtectHome = true;
   PrivateTmp = true;
   NoNewPrivileges = true;
   CapabilityBoundingSet = "";
   AmbientCapabilities = "";
   RestrictAddressFamilies = [ "AF_INET" "AF_INET6" ];

   ExecStart = pkgs.writeShellScript "dns-guard-runtime" ''
     set -euo pipefail
     TOKEN=$(cat -- "${cfTokenFile}")
     ZONE_DATA=$(${pkgs.curl}/bin/curl -sSf -X GET "https://api.cloudflare.com/client/v4/zones" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json")
     ZONE_ID=$(echo "$ZONE_DATA" | ${pkgs.jq}/bin/jq -r ".result[0].id")
     if [ -z "$ZONE_ID" ] || [ "$ZONE_ID" = "null" ]; then exit 1; fi
     EXISTING_RECORDS=$(${pkgs.curl}/bin/curl -sSf "https://api.cloudflare.com/client/v4/zones/$ZONE_ID/dns_records?per_page=100" -H "Authorization: Bearer $TOKEN" -H "Content-Type: application/json" | ${pkgs.jq}/bin/jq -r ".result[].name")
     GLOBAL_CONFLICT=false
     for record in $EXISTING_RECORDS; do if [[ "$record" == "*.${domain}" ]]; then GLOBAL_CONFLICT=true; break; fi; done
     ${pkgs.jq}/bin/jq -n --argjson conflict "$GLOBAL_CONFLICT" --arg domain "${domain}" '{useNixSubdomain: $conflict, baseDomain: $domain}' > "${runtimeDnsMap}"
   '';
 };
 path = with pkgs; [ curl jq coreutils gnugrep ];
 };
 systemd.timers.dns-guard = { wantedBy = [ "timers.target" ]; timerConfig = { OnBootSec = "1min"; OnUnitActiveSec = "30min"; RandomizedDelaySec = "60"; }; };
 };
}
