# ---NIXMETA
# ---
# domain: 50
# id: "NIXH-50-MED-003"
# title: "Download Stack"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [media,download,sabnzbd]
# description: "SABnzbd download manager."
# path: "modules/50-media/52-download.nix"
# provides: [my.media.downloads]
# requires: []
# links:
#   adr: docs/adr/ADR-52-download.md
#   guide: docs/guides/52-download.md
#   module: modules/50-media/52-download.nix
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
  options.my.media.downloads = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
  };

  config = lib.mkIf config.my.media.downloads.enable {
    services.sabnzbd.enable = true;
  };
}
