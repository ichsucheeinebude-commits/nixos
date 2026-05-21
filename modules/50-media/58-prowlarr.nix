# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-009"
# title: "Prowlarr"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,prowlarr,indexer]
# description: "Prowlarr indexer manager."
# path: "modules/50-media/58-prowlarr.nix"
# provides: [my.media.prowlarr]
# requires: []
# links:
#   adr: docs/adr/ADR-58-prowlarr.md
#   guide: docs/guides/58-prowlarr.md
#   module: modules/50-media/58-prowlarr.nix
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
  options.my.media.prowlarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 9696; };
  };
}
