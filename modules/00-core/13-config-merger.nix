# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-007"
# title: "Config Merger"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [core,config,merger,json,runtime-config,user-overrides]
# description: "Dynamic bridge between NixOS declarations and user-managed JSON overrides for runtime service reloads."
# path: "modules/00-core/13-config-merger.nix"
# provides: [my.core.configMerger]
# requires: [my.core.identity, my.core.server]
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core/13-config-merger.nix
#   source: "grapefruit89/mynixos/blob/main/00-core/config-merger.nix"
#   upstream: https://jqlang.github.io/jq/
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# NixOS-Konfigurationen sind deklarativ und benötigen einen Rebuild für
# Änderungen. Runtime-Services wie Caddy oder Pocket-ID können jedoch
# dynamische Konfigurationen aus JSON-Dateien lesen, die ohne Rebuild
# aktualisiert werden können.
#
# ### Entscheidung
#
# **Config Merger Pattern:**
# 1.  **Nix Defaults** — Identität, IPs, Domain aus NixOS-Konfiguration.
# 2.  **User JSON Overrides** — `/var/lib/nixhome/user-config.json` für Runtime-Anpassungen.
# 3.  **jq Deep Merge** — User-Overrides werden mit Nix-Defaults gemergt (jq `*` operator).
# 4.  **Run-Time Output** — Ergebnis in `/run/nixhome/config.json` (tmpfs, keine Persistenz).
# 5.  **Reload Service** — `nixhome-apply` Skript mergt und reloadet Services.
#
# ### SRE-Standards
#
# - Merge-Reihenfolge: Nix-Defaults * User-Overrides (Overrides gewinnen).
# - Output in /run (tmpfs) — keine Persistenz über Neustarts.
# - Service reload nur wenn aktiv (systemctl is-active check).
# - User-Config wird mit 0644 erstellt (lesbar für Services).
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  runDir = "/run/nixhome";
  userConfig = "/var/lib/nixhome/user-config.json";
  finalConfig = "${runDir}/config.json";

  # ── NixOS Defaults as JSON ──
  nixDefaults = pkgs.writeText "nix-defaults.json" (builtins.toJSON {
    domain   = config.my.core.identity.domain;
    email    = config.my.core.identity.email or "";
    lanIP    = config.my.core.identity.lanIP or "";
    hostName = config.my.core.identity.host;
  });

  # ── Merger Script ──
  mergerScript = pkgs.writeShellScript "nixhome-config-merger" ''
    set -euo pipefail
    mkdir -p ${runDir}
    if [ ! -f "${userConfig}" ]; then
      echo "{}" > "${userConfig}"
      chown root:root "${userConfig}"
      chmod 644 "${userConfig}"
    fi
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${nixDefaults}" "${userConfig}" > "${finalConfig}.tmp"
    mv "${finalConfig}.tmp" "${finalConfig}"
    chmod 644 "${finalConfig}"
  '';

  # ── Apply Script (merge + reload) ──
  applyScript = pkgs.writeShellScriptBin "nixhome-apply" ''
    set -euo pipefail
    echo "🔄 Merging configuration..."
    systemctl start nixhome-config-merger.service
    echo "🚀 Reloading services..."
    if systemctl is-active caddy >/dev/null 2>&1; then
      systemctl reload caddy
    fi
    echo "✨ Done!"
  '';
in
{
  options.my.core.configMerger = {
    enable = lib.mkEnableOption "Config merger (Nix defaults + user JSON overrides)";
    userConfigPath = lib.mkOption {
      type = lib.types.str;
      default = userConfig;
      description = "Path to user-provided JSON overrides file.";
    };
  };

  config = lib.mkIf config.my.core.configMerger.enable {
    # ── Merger Service ──
    systemd.services.nixhome-config-merger = {
      description = "Merge Nix Defaults with User JSON Config";
      before = [ "caddy.service" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = mergerScript;
      };
    };

    # ── CLI Tool ──
    environment.systemPackages = [ applyScript pkgs.jq ];

    # ── User Config Directory ──
    systemd.tmpfiles.rules = [
      "d /var/lib/nixhome 0755 root root -"
    ];
  };
}
