# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-MTX-001"
# title: "Matrix Conduit"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [matrix, chat]
# description: "Matrix Conduit module."
# path: "modules/60-apps/65-matrix-conduit.nix"
# provides: [my.apps.matrix]
# requires: [10-network/10-network]
# links:
#   adr: docs/adr/ADR-60-matrix-conduit.md
#   guide: docs/guides/60-matrix-conduit.md
#   module: modules/60-apps/65-matrix-conduit.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-060-SOC-CON-001",
#   "title": "Matrix Conduit",
#   "layer": 60,
#   "category": "services/matrix",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["matrix", "conduit", "chat", "rust", "hardened"],
#   "description": "Lightweight Matrix homeserver (Conduit) written in Rust."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, myLib, ... }:
let
 
 port = config.my.ports.matrix;
 domain = config.my.configs.identity.domain;
 subdomain = config.my.configs.identity.subdomain;
 serverName = "matrix.${subdomain}.${domain}";
 serviceBase = myLib.mkService { inherit config; name = "matrix"; port = port; useSSO = false; description = "Matrix Homeserver (Conduit)"; };
in
{
 options.my.meta.matrix_conduit = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for matrix-conduit module";
 };


 config = lib.mkIf config.my.services.matrixConduit.enable (lib.mkMerge [
 (lib.filterAttrs (n: v: n != "systemd") serviceBase)
 {
 services.matrix-conduit = {
 enable = true;
 settings.global = {
 server_name = serverName;
 port = port;
 address = "127.0.0.1";
 database_backend = "rocksdb";
 allow_registration = lib.mkDefault false;
 };
 };
 systemd.services.conduit = { serviceConfig = lib.mkMerge [ serviceBase.systemd.services.matrix.serviceConfig { StateDirectory = lib.mkForce "matrix-conduit"; ReadWritePaths = lib.mkForce [ "${config.my.configs.paths.stateDir}/matrix-conduit" ]; MemoryDenyWriteExecute = lib.mkForce false; CPUWeight = lib.mkForce 50; MemoryMax = lib.mkForce "1G"; } ]; };
 # 🌐 MATRIX FEDERATION (anchor: matrix-federation)
 services.caddy.virtualHosts."${serverName}".extraConfig = lib.mkAfter ''
 handle /.well-known/matrix/server {
 header Content-Type application/json
 respond `{"m.server":"${serverName}:443"}`
 }
 handle /.well-known/matrix/client {
 header Content-Type application/json
 header Access-Control-Allow-Origin *
 respond `{"m.homeserver":{"base_url":"https://${serverName}"}}`
 }
 '';
 }
 ]);
}
