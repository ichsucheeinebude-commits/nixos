# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-060-APP-VLT-001",
#   "title": "Vaultwarden Password Manager",
#   "layer": 60,
#   "category": "services/security",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["security", "passwords", "vault", "hardened", "socket-activation"],
#   "description": "Tightly sandboxed password manager with Wake-on-Access (Socket Activation)."
# }
# ---ENDNIXMETA

{
 config,
 lib,
 myLib,
 ...
}:
 let
 # 🚀 NMS v4.1 Metadaten
 nms = {
 id = "NIXH-60-APP-007";
 title = "Vaultwarden (SRE Exhausted)";
 description = "Tightly sandboxed password manager with Wake-on-Access (Socket Activation).";
 layer = 60;
 nixpkgs.category = "services/security";
 capabilities = ["security/passwords" "security/socket-activation"];
 audit.last_reviewed = "2026-03-03";
 audit.complexity = 2;
 };

 port = config.my.ports.vaultwarden;
 # 🔑 SOPS Secret Identifier: vaultwarden_env
 secretEnv = config.sops.secrets.vaultwarden_env.path;
in {
 options.my.meta.vaultwarden = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for vaultwarden module";
 };

 options.my.services.vaultwarden = {
   enable = lib.mkEnableOption "Vaultwarden Password Manager";
 };

 config = lib.mkIf config.my.services.vaultwarden.enable (lib.mkMerge [
   (myLib.mkService {
     inherit config;
     name = "vaultwarden";
     port = port;
     useSSO = true;
     description = "Vaultwarden Password Vault";
     persist = true;
     extraServiceConfig = {
       wantedBy = lib.mkForce []; # Handled by socket activation
       requires = ["vaultwarden.socket"];
       after = ["vaultwarden.socket"];
       RuntimeDirectory = "vaultwarden";
       MemoryDenyWriteExecute = lib.mkForce true;
     };
   })
   {
     # 🔐 VAULTWARDEN SECRETS (anchor: vaultwarden-secrets)
     services.vaultwarden = {
       enable = true;
       config = {
         ROCKET_ADDRESS = "127.0.0.1";
         ROCKET_PORT = port;
         SIGNUPS_ALLOWED = false;
         INVITATIONS_ALLOWED = true;
         SHOW_PASSWORD_HINT = false;
         DATABASE_MAX_CONNS = 10;
       };
       environmentFile = secretEnv;
     };

     systemd.sockets.vaultwarden = {
       description = "Vaultwarden Socket";
       wantedBy = ["sockets.target"];
       listenStreams = [ "/run/vaultwarden/vaultwarden.sock" ];
       socketConfig = {
         SocketMode = "0660";
         SocketUser = "vaultwarden";
         SocketGroup = "caddy";
       };
     };

     systemd.services.vaultwarden.restartTriggers = [
       config.services.vaultwarden.package
       config.services.vaultwarden.environmentFile
     ];
   }
 ]);
}
/**
* ---
 * technical_integrity:
 * checksum: sha256:10236f4c9d6f8efdb21ef6861bedb38de3d36660e1ae3010fd9ae61566bc3abf
 * eof_marker: NIXHOME_VALID_EOF* ---
*/

