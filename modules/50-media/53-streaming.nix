# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-004"
# title: "Streaming Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,streaming,jellyfin]
# description: "Jellyfin, Navidrome, Audiobookshelf streaming."
# path: "modules/50-media/53-streaming.nix"
# provides: [my.media.streaming]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/53-streaming.nix
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
  options.my.media.streaming = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    gpuAcceleration = lib.mkEnableOption "Intel GPU hardware transcoding";
  };

  config = lib.mkIf config.my.media.streaming.enable {
    services.jellyfin.enable = true;
    services.navidrome.enable = true;
    services.audiobookshelf.enable = true;
    hardware.graphics.enable = lib.mkIf config.my.media.streaming.gpuAcceleration true;
  };
}
