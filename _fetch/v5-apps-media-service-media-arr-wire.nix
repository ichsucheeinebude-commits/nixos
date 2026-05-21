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
 # 🚀 NMS v4.2 Metadaten (Arr-Wire)
 # Fragment-Sourcing:
 # - Fragment nixarr/vpn: Orchestration pattern
 # - ADR 001: Horizontal Decoupling
 nms = {
 id = "NIXH-01-APP-ARR-WIR";
 title = "Arr-Wire (VPN Orchestration)";
 description = "Wires downloader services into specialized VPN namespaces.";
 layer = 40;
 nixpkgs.category = "services/media";
 capabilities = ["network/vpn" "automation/wiring"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 2;
 };

 # Wir definieren einen zentralen Namespace für alle Downloader (SRE-Standard)
 # Alternative: Ein Namespace pro Dienst. Wir wählen "media-vault" für Effizienz.
in {
 options.my.meta.arr_wire = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 config = lib.mkIf config.my.services.vpnConfinement.enable {
 # 🔗 1. NAMESPACE DEFINITION
 my.services.vpnConfinement.namespaces.media-vault = {
 wgConf = "/etc/nixos/secrets/vpn/privado-de.conf"; # Sops-Pfad
 killSwitch = true;
 };

 # 🚦 2. SERVICE WIRING
 # Wir weisen die Dienste dem Namespace zu
 my.media.sabnzbd.useVPN = true;
 my.media.sonarr.useVPN = true;
 my.media.radarr.useVPN = true;
 
 # Hinweis: Da mkService 'useVPN' unterstützt, erfolgt das Routing 
 # nun automatisch über 'NetworkNamespacePath' im systemd-Service.
 };
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:d13e9a7b9600bfbd98bc1057589bcf25b5b1b8aa890de35898f63eb3211fd04f9\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
