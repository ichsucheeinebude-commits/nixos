{
  lib,
  config,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-025";
    title = "Ports (SRE Master Source)";
    description = "Central port registry for consistent 10k/20k schema mapping with duplicate detection.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = ["ssot/ports" "networking/registry"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 1;
  };

  # Hilfsfunktion für Port-Validierung
  allPorts = lib.attrValues config.my.ports;
  hasDuplicates = (lib.length (lib.unique allPorts)) != (lib.length allPorts);
in {
  options.my.meta.ports = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for ports module";
  };

  options.my.ports = lib.mkOption {
    type = lib.types.attrsOf lib.types.port;
    default = {};
    description = "Zentrales Port-Register.";
  };

  config = {
    my.ports = {
      # ── SYSTEM & EDGE ────────────────────────────────────────────────────────
      ssh = 53844;
      edgeHttps = 443;

      # ── 10-INFRASTRUCTURE (10xxx) ───────────────────────────────────────────
      adguard = 10000;
      uptimeKuma = 10001;
      pocketId = 10010;
      homepage = 10082;
      netdata = 10999;
      valkey = 6379;
      olivetin = 10080;
      cockpit = 10090;
      ddnsUpdater = 10100;

      # ── 20-SERVICES (20xxx) ─────────────────────────────────────────────────
      jellyfin = 20096;
      vaultwarden = 20002;
      n8n = 20017;
      paperless = 20981;
      ollama = 11434;
      sonarr = 20989;
      radarr = 20878;
      lidarr = 20686;
      prowlarr = 20696;
      readarr = 20787;
      sabnzbd = 20080;
      jellyseerr = 25055;
      matrix = 20006;
      audiobookshelf = 20081;
      readeck = 20005;
      scrutiny = 20007;
      miniflux = 20008;
      filebrowser = 20001;
      karakeep = 20003;
      openWebui = 20009;
      monica = 20004;
      linkwarden = 3000;

      # ── IOT & MESSAGING ──────────────────────────────────────────────────────
      zigbee2mqtt = 28080;
      mqtt = 1883;
    };

    # SRE Safety: Warnung bei Port-Kollision
    warnings = lib.optional hasDuplicates "⚠️ [SRE-WARNUNG] Doppelte Port-Zuweisung im Register erkannt!";
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:a95d4848bd83c6b5d62d9655981db4b8945717e4cde0e3f82f27e50e1bc0bc01
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

