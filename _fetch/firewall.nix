{
  lib,
  config,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-011";
    title = "Firewall (nftables Pro)";
    description = "Modern nftables configuration with clean separation of zones and trusted network segments.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = ["network/firewall" "security/nftables"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  bastelmodus = config.my.configs.bastelmodus;
  sshPort = config.my.ports.ssh;
  lanCidrs = config.my.configs.network.lanCidrs;
  tailnetCidrs = config.my.configs.network.tailnetCidrs;
  rfc1918 = lib.concatStringsSep ", " lanCidrs;
  tailnet = lib.concatStringsSep ", " tailnetCidrs;
in {
  options.my.meta.firewall = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for firewall module";
  };

  config = {
    networking.nftables.enable = true;
    networking.firewall = {
      enable = !bastelmodus;
      trustedInterfaces = ["tailscale0" "lo"];
      allowedTCPPorts = lib.mkForce [
        config.my.ports.edgeHttps
        80
        sshPort
        22 # Legaler Rettungsweg
      ];

      # Nixpkgs Native Extra Rules
      extraInputRules = lib.mkForce ''
        ip saddr { ${rfc1918}, ${tailnet} } tcp dport 53 accept
        ip saddr { ${rfc1918}, ${tailnet} } udp dport 53 accept
        ip saddr { ${rfc1918} } udp dport 5353 accept
        ip protocol icmp accept
      '';

      logRefusedConnections = false;
    };
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:e918cb5d57d4499c77e11342fca451e92f6cd82723a69131a8b84c7bec01214f
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

