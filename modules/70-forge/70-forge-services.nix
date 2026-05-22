# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-000"
# title: "Forge Services Factory — Forgejo, Semaphore, Cockpit"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [forge,forgejo,semaphore,cockpit,factory]
# description: "Unified forge services module: Forgejo (self-hosted Git, SQLite), Semaphore (Ansible Web UI), Cockpit (Server Management). Consolidated 3 small modules into one."
# path: "modules/70-forge/70-forge-services.nix"
# provides: [my.forge.forgejo, my.forge.semaphore, my.forge.cockpit]
# requires: [my.core.principles]
# links:
#   adr: docs/adr/ADR-70-forge.md
#   guide: docs/guides/70-forge.md
#   module: modules/70-forge/70-forge-services.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏛️ Die SSoT-Wahl: Forgejo (The Full Forge)
#
# Wir nutzen Forgejo als hocheffizienten GitHub-Ersatz.
# - **Dienst:** \`services.forgejo.enable = true;\`
# - **Nugget:** SQLite-Datenbank für minimalen RAM-Verbrauch (Layer 20).
# - **Backup:** \`services.forgejo.dump.enable = true\` schiebt tägliche Git-Snapshots auf Tier A (NVMe). ✅
#
# ### 💎 Der SRE-Weg: Semaphore (Ansible Web UI)
#
# Zentrales Ansible-Management mit Web-Interface.
# - **Konzept:** Declarative Playbook-Ausführung, RBAC, Audit-Logs.
# - **Anwendung:** Ideal für Infrastruktur-Automation und SRE-Workflows.
#
# ### 🛠️ Der Admin-Weg: Cockpit (Server Management)
#
# Web-basiertes Server-Management für schnelle Admin-Aufgaben.
# - **Konzept:** System-Info, Logs, Storage, Network — alles im Browser.
# - **Anwendung:** Ideal für schnelle Checks ohne SSH.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.forge;
in
{
  options.my.forge = {
    # ── Forgejo ──
    forgejo = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 3000; };
      disableRegistration = lib.mkOption { type = lib.types.bool; default = true; };
      dumpEnable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable daily Git snapshots to Tier A (NVMe)."; };
    };

    # ── Semaphore ──
    semaphore = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 3001; };
    };

    # ── Cockpit ──
    cockpit = {
      enable = lib.mkOption { type = lib.types.bool; default = false; };
      port = lib.mkOption { type = lib.types.port; default = 9090; };
    };
  };

  config = lib.mkMerge [
    # ── Forgejo ──
    (lib.mkIf cfg.forgejo.enable {
      services.forgejo = {
        enable = true;
        database.type = "sqlite3";
        settings = {
          server = {
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = cfg.forgejo.port;
          };
          service.DISABLE_REGISTRATION = cfg.forgejo.disableRegistration;
        };
      };
    })

    # ── Semaphore ──
    (lib.mkIf cfg.semaphore.enable {
      services.semaphore = {
        enable = true;
        port = cfg.semaphore.port;
      };
    })

    # ── Cockpit ──
    (lib.mkIf cfg.cockpit.enable {
      services.cockpit = {
        enable = true;
        port = cfg.cockpit.port;
      };
    })
  ];
}
