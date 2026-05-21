# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-004"
# title: "Hardware Profile"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [core,hardware,cpu,gpu,microcode]
# description: "CPU microcode, GPU drivers, and hardware-specific configuration."
# path: "modules/00-core/03-hardware-profile.nix"
# provides: [my.core.hardware]
# requires: []
# links:
#   adr: docs/adr/ADR-placeholder.md
#   guide: docs/guides/placeholder.md
#   module: modules/00-core/03-hardware-profile.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: MODULARITÄT OHNE SCHMERZ (KISS)
#
# In herkömmlichen Nix-Systemen musst du jede neue Datei manuell in einer Liste eintragen. In unserem System ist das vorbei:
# - **Prinzip:** "Jede Datei ist ein Modul".
# - **Aktion:** Erstelle eine `.nix` Datei im Ordner `features/` – sie wird sofort vom System erkannt und geladen.
# - **Vorteil:** Du kannst dich auf das Konfigurieren konzentrieren, anstatt dich um Import-Strukturen zu kümmern.
#
# ---
# ### A. Die Engine: `flake-parts` & `den`
#
# Wir nutzen `flake-parts` als Basis und das `den` Framework zur Kontext-Steuerung.
# - **Auto-Import:** Integration von `import-tree`, um das gesamte Verzeichnis `./modules` rekursiv zu evaluieren.
# - **Deferred Modules:** Wir nutzen den Typ `deferredModule` aus Nixpkgs für Sub-Module, um Konflikte beim Mergen von Attributen (z.B. Firewall-Regeln) zu minimieren.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.my.core.principles.enable (let
    cpu = config.my.core.hardware.cpuType;
    intelGpu = config.my.core.hardware.intelGpu;
  in lib.mkMerge [
    (lib.mkIf (cpu == "intel") { hardware.cpu.intel.updateMicrocode = lib.mkDefault true; })
    (lib.mkIf (cpu == "amd")   { hardware.cpu.amd.updateMicrocode = lib.mkDefault true; })
    (lib.mkIf intelGpu {
      hardware.graphics = {
        enable = lib.mkDefault true;
        extraPackages = lib.mkDefault [ pkgs.intel-media-driver pkgs.intel-compute-runtime ];
        enable32Bit = lib.mkDefault true;
      };
    })
  ]);
}
