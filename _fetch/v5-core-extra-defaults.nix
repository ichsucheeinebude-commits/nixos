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

{config, lib, ...}: let
 # 🚀 NMS v4.2 Metadaten
 nms = {
 id = "NIXH-00-COR-009";
 title = "00-defaults";
 description = "Shared global defaults for network namespaces, filesystem prefixes, and security conventions.";
 layer = 0;
 nixpkgs.category = "system/settings";
 capabilities = ["architecture/defaults" "storage/tiering"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 2;
 };
in {
 options.my.meta.defaults = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 description = "NMS metadata for defaults module";
 };

 options.my.defaults = {
 # -------------------------------------------------------------------------
 # Netzwerk
 # -------------------------------------------------------------------------
 netns = lib.mkOption {
 type = lib.types.nullOr lib.types.str;
 default = null;
 description = "Standard Network-Namespace für alle Dienste.";
 };

 bindAddress = lib.mkOption {
 type = lib.types.str;
 default = "127.0.0.1";
 description = "Standard-Bind-Adresse für alle Dienste.";
 };

 # -------------------------------------------------------------------------
 # Lokalisierung
 # -------------------------------------------------------------------------
 locale = {
 timezone = lib.mkOption {
 type = lib.types.str;
 default = "Europe/Berlin";
 };
 language = lib.mkOption {
 type = lib.types.str;
 default = "de_DE.UTF-8";
 };
 dateOrder = lib.mkOption {
 type = lib.types.enum ["DMY" "MDY" "YMD"];
 default = "DMY";
 };
 };

 # -------------------------------------------------------------------------
 # OCR
 # -------------------------------------------------------------------------
 ocr = {
 languages = lib.mkOption {
 type = lib.types.listOf lib.types.str;
 default = ["deu" "eng"];
 };
 outputType = lib.mkOption {
 type = lib.types.enum ["pdfa" "pdfa-1" "pdfa-2" "pdfa-3" "pdf" "none"];
 default = "pdfa";
 };
 };

 # -------------------------------------------------------------------------
 # Dateisystem-Präfixe (ABC-Tiering)
 # -------------------------------------------------------------------------
 paths = {
 statePrefix = lib.mkOption {
 type = lib.types.str;
 default = "/data/state";
 };
 mediaRoot = lib.mkOption {
 type = lib.types.str;
 default = "/mnt/media";
 };
 downloadsDir = lib.mkOption {
 type = lib.types.str;
 default = "/mnt/media/downloads";
 };
 fastPoolRoot = lib.mkOption {
 type = lib.types.str;
 default = "/mnt/fast-pool";
 };
 documentRoot = lib.mkOption {
 type = lib.types.str;
 default = "/mnt/documents";
 };
 backupRoot = lib.mkOption {
 type = lib.types.str;
 default = "/mnt/backup";
 };
 };

 # -------------------------------------------------------------------------
 # Sicherheit
 # -------------------------------------------------------------------------
 security = {
 defaultGroup = lib.mkOption {
 type = lib.types.str;
 default = "media";
 };
 ssoEnable = lib.mkOption {
 type = lib.types.bool;
 default = true;
 };
 };

 # -------------------------------------------------------------------------
 # Observability
 # -------------------------------------------------------------------------
 observability = {
 logLevel = lib.mkOption {
 type = lib.types.enum ["DEBUG" "INFO" "WARNING" "ERROR"];
 default = "WARNING";
 };
 metricsPortOffset = lib.mkOption {
 type = lib.types.int;
 default = 9000;
 };
 };
 };

 config = {
 boot.kernel.sysctl."vm.swappiness" = lib.mkDefault (if config.zramSwap.enable then 180 else 10);
 };
}
