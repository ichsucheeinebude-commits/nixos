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

{ config, lib, pkgs, ... }:
let
 # 🚀 NMS v4.2 Metadaten (VPN Confinement)
 # Fragment-Sourcing:
 # - Fragment nixarr/vpn-confinement: Maroka-chan implementation
 # - Fragment 18265: nftables hardening for namespaces
 nms = {
 id = "NIXH-01-SRV-VPN-001";
 title = "VPN Confinement (Maroka-chan based)";
 description = "Isolated network namespaces for VPN-bound services with kill-switch protection.";
 layer = 10;
 nixpkgs.category = "network/vpn";
 capabilities = ["network/isolation" "network/vpn" "security/kill-switch"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 3;
 };

 cfg = config.my.services.vpnConfinement;
 srePaths = config.my.configs.paths;

in {
 options.my.meta.vpn_confinement = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 options.my.services.vpnConfinement = {
 enable = lib.mkEnableOption "VPN Confinement for services";
 
 namespaces = lib.mkOption {
 type = lib.types.attrsOf (lib.types.submodule {
 options = {
 wgConf = lib.mkOption { 
 type = lib.types.path; 
 description = "Path to WireGuard config (via Sops, absolute path)";
 };
 killSwitch = lib.mkOption { 
 type = lib.types.bool; 
 default = true; 
 description = "Strictly block non-VPN traffic in this namespace";
 };
 };
 });
 default = {};
 description = "Definitions of isolated VPN namespaces";
 };
 };

 config = lib.mkIf cfg.enable {
 # 🛡️ 1. SETUP NAMESPACES
 systemd.services = lib.mapAttrs' (name: nsCfg: (
 let nsName = name; in
 lib.nameValuePair "netns-${nsName}" {
 description = "Network Namespace ${nsName}";
 before = [ "network.target" ];
 wantedBy = [ "multi-user.target" ];
 
 path = with pkgs; [ iproute2 wireguard-tools nftables ];
 
 # anchor: netns-setup
 serviceConfig = {
 Type = "oneshot";
 RemainAfterExit = true;
 ExecStart = pkgs.writeShellScript "netns-${nsName}-up" ''
 # Create namespace if missing
 ip netns add ${nsName} || true
 ip netns exec ${nsName} ip link set lo up

 # Setup WireGuard in Namespace
 ip link add wg0 type wireguard
 ip link set wg0 netns ${nsName}
 ip netns exec ${nsName} wg setconf wg0 ${nsCfg.wgConf}
 ip netns exec ${nsName} ip link set wg0 up

 # Route all traffic through wg0
 ip netns exec ${nsName} ip route add default dev wg0

 # 🛡️ 2. KILL-SWITCH (KRIT-03)
 ${lib.optionalString nsCfg.killSwitch ''
 # anchor: vpn-killswitch
 echo "🛡️ Enforcing Kill-Switch for namespace ${nsName}..."
 ip netns exec ${nsName} nft add table inet killswitch
 ip netns exec ${nsName} nft add chain inet killswitch output \
   "{ type filter hook output priority 0; policy drop; }"
 ip netns exec ${nsName} nft add rule inet killswitch output \
   oifname { "wg0", "lo" } accept
 ''}
 # 🛡️ 3. HEALTHCHECK & ALERTING (H-02)
 echo "🔍 Testing VPN connectivity in namespace ${nsName}..."
 if ! ip netns exec ${nsName} ${pkgs.iputils}/bin/ping -c 1 -W 5 1.1.1.1 > /dev/null; then
 echo "❌ VPN Healthcheck FAILED! Triggering alert..."
 # Source: Fragment 2829 (ntfy-sh hook)
 if [ -f /etc/nixos/secrets/ntfy-sh ]; then
 ${pkgs.curl}/bin/curl -H "Priority: urgent" -H "Tags: skull,fire" \
 -d "VPN Namespace ${nsName} setup failed: No connectivity!" \
 $(cat /etc/nixos/secrets/ntfy-sh)
 fi
 exit 1
 fi
 echo "✅ VPN Namespace ${nsName} is UP and CONNECTED."
 '';
 ExecStop = pkgs.writeShellScript "netns-${nsName}-down" ''
 ip netns del ${nsName} || true
 '';
 };
 }
 )) cfg.namespaces;

 # 💾 PERSISTENCE (Tier A)
 # The wgConf is usually in /persist/etc/nixos/secrets/wg.conf
 # This is handled by Sops normally.
 };
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:d13e9a7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04f9\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
