# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-006"
# title: "Jellyfin"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,jellyfin,streaming]
# description: "Jellyfin media server with hardware acceleration."
# path: "modules/50-media/55-jellyfin.nix"
# provides: [my.media.jellyfin]
# requires: []
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/55-jellyfin.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Wir implementieren den Medien-Stack (Layer 40). Wir wollen die Sicherheit von `nixarr` und die Performance von `nixflix`, aber ohne deren architektonische Altlasten.
# ### Entscheidung
#
# Wir implementieren eine "Hybrid-Engine":
# 1.  **VPN-Isolation:** Wir nutzen das Namespace-Pattern von `nixarr` (Native NixOS netns).
# 2.  **Hardware:** Wir nutzen die QuickSync-Optimierungen von `nixflix` (iHD Driver).
# 3.  **Struktur:** Wir nutzen das **mynixos v8.0 Flat-Dendritic Pattern**.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.media.jellyfin = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    gpuAcceleration = lib.mkOption { type = lib.types.bool; default = false; };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/jellyfin"; };
  };

  config = lib.mkIf config.my.media.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      dataDir = config.my.media.jellyfin.dataDir;
    };
  };
}
