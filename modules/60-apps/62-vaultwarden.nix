# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-VLT-001"
# title: "Vaultwarden Passwords"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [vaultwarden, passwords]
# description: "Vaultwarden Passwords module."
# path: "modules/60-apps/62-vaultwarden.nix"
# provides: [my.apps.vaultwarden]
# requires: [20-security/22-secrets]
# links:
#   adr: docs/adr/ADR-60-vaultwarden.md
#   guide: docs/guides/60-vaultwarden.md
#   module: modules/60-apps/62-vaultwarden.nix
# ---
# ---ENDNIXMETA
{
 config,
 lib,
 myLib,
 ...
}:
 let
 
 port = config.my.ports.vaultwarden;
 secretEnv = config.sops.secrets.vaultwarden_env.path;
in {

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
