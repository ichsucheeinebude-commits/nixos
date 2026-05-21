# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-59-LID-001"
# title: "Lidarr Music Downloader"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media, lidarr, music, automation]
# description: "Lidarr for automated music downloading and library management."
# path: "root/modules/50-media/59-lidarr.nix"
# provides: [my.media.lidarr]
# requires: [00-core/00-principles, 50-media/51-arr-stack]
# links:
#   adr: ADR-59-lidarr.md
#   guide: 59-lidarr.md
#   module: root/modules/50-media/59-lidarr.nix
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

{ config, lib, pkgs, utils, myLib, ... }:
let
  arrFactory = import ./_arr-factory.nix { inherit config lib pkgs utils myLib; };
in
arrFactory.mkArr {
  name = "lidarr";
  description = "Lidarr Music Downloader";
  id = "NIXH-01-APP-LID-001";
  port = 8686;
  extraReadWritePaths = [ 
    config.my.configs.paths.mediaLibrary
    config.my.configs.paths.downloads
  ];
}
