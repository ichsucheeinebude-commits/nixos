# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-002"
# title: "Arr Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,arr,radarr,sonarr,prowlarr]
# description: "*Arr media management stack."
# path: "modules/50-media/51-arr-stack.nix"
# provides: [my.media.arr]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/50-media/51-arr-stack.nix
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
  options.my.media.arr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    radarrPort = lib.mkOption { type = lib.types.port; default = 7878; };
    sonarrPort = lib.mkOption { type = lib.types.port; default = 8989; };
    prowlarrPort = lib.mkOption { type = lib.types.port; default = 9696; };
  };

  config = lib.mkIf config.my.media.arr.enable {
    services.radarr.enable = true;
    services.sonarr.enable = true;
    services.prowlarr.enable = true;
  };
}
