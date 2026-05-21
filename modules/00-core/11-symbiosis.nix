# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-033"
# title: "Symbiosis"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [core,hardware,microcode,discovery]
# description: "Hardware abstraction layer with auto-discovery and microcode management."
# path: "modules/00-core/11-symbiosis.nix"
# provides: [my.core.symbiosis]
# requires: [my.core.hardware]
# links:
#   adr: pending
#   guide: pending
#   module: modules/00-core/11-symbiosis.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# CPU-Microcode-Updates sind kritisch für Systemsicherheit (Spectre, Meltdown).
# Das System muss Intel vs. AMD automatisch erkennen und das richtige Microcode
# laden. Zusätzlich: RAM-Warnungen bei unterdimensionierten Systemen.
#
# ### Entscheidung
#
# **Hardware-Discovery Pattern:**
# 1.  **Microcode Auto-Select** — basierend auf cpuType (intel/amd).
# 2.  **RAM-Warnung** — System-Warnung wenn < 4GB RAM erkannt.
# 3.  **HW-Profil-Age-Check** — Prüft ob Hardware-Profil veraltet ist (>30 Tage).
# 4.  **nixhome-detect-hw** — CLI-Tool zur Hardware-Erkennung.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cpuType = config.my.core.hardware.cpuType or "unknown";
  ramGB = config.my.core.hardware.ramGB or 0;
in
{
  options.my.core.symbiosis = {
    enable = lib.mkEnableOption "Hardware abstraction and microcode management";
  };

  config = lib.mkIf config.my.core.symbiosis.enable {
    # ── CPU Microcode ──
    hardware.cpu.intel.updateMicrocode = lib.mkIf (cpuType == "intel") true;
    hardware.cpu.amd.updateMicrocode = lib.mkIf (cpuType == "amd") true;

    # ── Hardware Warnings ──
    warnings = lib.optional (ramGB < 4)
      "⚠️ [HARDWARE-WARNUNG] Weniger als 4GB RAM erkannt (${toString ramGB}GB).";

    # ── Hardware Discovery Script ──
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "nixhome-detect-hw" ''
        set -euo pipefail
        echo '🔍 Hardware Discovery...'
        RAM=$(free -g | awk '/^Mem:/ {print $2}')
        CPU_VENDOR=$(lscpu | grep 'Vendor ID' | awk '{print $3}')
        echo "{\"ram_gb\": $RAM, \"cpu_vendor\": \"$CPU_VENDOR\"}"
      '')
    ];

    # ── Hardware Profile Age Check ──
    environment.etc."nixhome-hw-age-check".source = pkgs.writeShellScript "hw-check" ''
      CONFIG_FILE="/etc/nixos/hosts/$(hostname)/hardware-nixos.nix"
      if [ -f "$CONFIG_FILE" ]; then
        AGE=$(( $(date +%s) - $(stat -c %Y "$CONFIG_FILE") ))
        if [ $AGE -gt 2592000 ]; then
          echo '⚠️ Hardware-Profil ist älter als 30 Tage.'
          echo '   Ausführen: nixos-generate-config --show-hardware-config'
        fi
      fi
    '';
  };
}
