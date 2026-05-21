# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, pkgs, lib, ... }:
let
 # 🚀 NMS v4.0 Metadaten
 nms = {
 id = "NIXH-10-GTW-005";
 title = "Dns Automation";
 description = "Check Cloudflare for DNS conflicts and update runtime map for dynamic routing.";
 layer = 10;
 nixpkgs.category = "services/networking";
 capabilities = [ "network/dns-automation" "cloudflare/api" ];
 audit.last_reviewed = "2026-03-02";
 audit.complexity = 2;
 };

 runtimeDnsMap = "/var/lib/nixhome/dns-map-runtime.json";
 domain = config.my.configs.identity.domain;
 cfTokenFile = config.sops.secrets.cloudflare_token.path;
in
{
 options.my.meta.dns_automation = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for dns-automation module";
 };


 config = lib.mkIf config.my.services.dnsAutomation.enable {
 systemd.services.dns-guard = {
 description = "Check Cloudflare for DNS conflicts";
 after = [ "network-online.target" "sops-install-secrets.service" ];
 requires = [ "network-online.target" ];
 serviceConfig = {
   Type = "oneshot";
   StateDirectory = "nixhome";
   # 🛡️ SYSTEMD SANDBOXING
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
