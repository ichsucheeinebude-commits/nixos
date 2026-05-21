# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-PAP-001"
# title: "Paperless-ngx"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [paperless, documents]
# description: "Paperless-ngx module."
# path: "modules/60-apps/60-paperless.nix"
# provides: [my.apps.paperless]
# requires: [30-storage/30-storage]
# links:
#   adr: docs/adr/ADR-60-paperless.md
#   guide: docs/guides/60-paperless.md
#   module: modules/60-apps/60-paperless.nix
# ---
# ---ENDNIXMETA
{ config, lib, pkgs, myLib, ... }:
let
 # - NIXH-01-APP-PAP-001: Vorherige Version
 # - Fragment: Valkey Integration (Open-Source Redis Alternative)

 cfg = config.my.apps.paperless;
 srePaths = config.my.configs.paths;
 
in
{

  options.my.apps.paperless = {
    enable = lib.mkEnableOption "Paperless-ngx Document Management";
    secretFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default = config.sops.secrets.paperless_secret_key.path;
      description = "Path to Paperless Secret Key (via Sops)";
    };
  };

 config = lib.mkIf cfg.enable (lib.mkMerge [
 
 (myLib.mkService {
   inherit config;
   name = "paperless";
   port = config.my.ports.paperless or 28981;
   description = "Paperless-ngx Document Management";
   requiresPostgres = true;
   persist = true;
   useSSO = true;
 })

 {
 services.paperless = {
 enable = true;
 user = "paperless";
 address = "127.0.0.1";
 port = config.my.ports.paperless or 28981;
 };

 systemd.services.paperless-web = {
 environment = {
 PAPERLESS_URL = "https://paperless.${config.my.configs.identity.subdomain}.${config.my.configs.identity.domain}";
 PAPERLESS_TIME_ZONE = config.my.configs.locale.timezone;
 PAPERLESS_OCR_LANGUAGE = "deu+eng";
 
 # ABC-Tiering Paths (Source: ADR 852)
 PAPERLESS_DATA_DIR = "${srePaths.stateDir}/paperless";
 PAPERLESS_MEDIA_ROOT = "${srePaths.mediaLibrary}/documents/paperless";
 PAPERLESS_CONSUMPTION_DIR = "${srePaths.privateData}/consume/paperless";
 
 # Database & Valkey Wiring
 PAPERLESS_DBHOST = "/run/postgresql";
 PAPERLESS_DBNAME = "paperless";
 PAPERLESS_DBUSER = "paperless";
 # LHF-08: Point to correct Valkey socket
 PAPERLESS_REDIS = "unix://${config.services.redis.servers.valkey.settings.unixsocket}";
 };
 serviceConfig.EnvironmentFile = lib.optional (cfg.secretFile != null) cfg.secretFile;
 };

 systemd.services.paperless-consumer.restartTriggers = [
 config.services.paperless.package
 (lib.optionalString (config.services.paperless.passwordFile != null) config.services.paperless.passwordFile)
 ];

 systemd.services.paperless-web.restartTriggers = [
 config.services.paperless.package
 ];
 };

 {
   # Mirror environment to worker for processing
   systemd.services.paperless-worker.environment = config.systemd.services.paperless-web.environment;
 }
 ]);
}
