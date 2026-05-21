# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-001"
# title: "Media Library"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,library,factories]
# description: "Shared media library paths and factory helpers."
# path: "modules/50-media/50-lib-media.nix"
# provides: [my.media.library]
# requires: []
# links:
#   adr: docs/adr/ADR-50-media.md
#   guide: docs/guides/50-media.md
#   module: modules/50-media/50-lib-media.nix
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
  options.my.media.library = {
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/cache/media"; };
    downloads = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; };
    mediaArchive = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/media"; };
  };
}
