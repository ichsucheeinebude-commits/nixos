# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-003"
# title: "Cockpit Admin"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [forge,cockpit,admin]
# description: "Cockpit web administration."
# path: "modules/70-forge/72-cockpit.nix"
# provides: [my.forge.cockpit]
# requires: []
# links:
#   adr: docs/adr/ADR-72-cockpit.md
#   guide: docs/guides/72-cockpit.md
#   module: modules/70-forge/72-cockpit.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏛️ 1. Die SSoT-Wahl: Forgejo (The Full Forge)
#
# Wir nutzen Forgejo als hocheffizienten GitHub-Ersatz.
# - **Dienst:** \`services.forgejo.enable = true;\`
# - **Nugget:** Wir nutzen \`services.forgejo.database.type = "sqlite3"\` für minimalen RAM-Verbrauch (Layer 20).
# - **Backup:** \`services.forgejo.dump.enable = true\` schiebt tägliche Git-Snapshots auf Tier A (NVMe). ✅
# ### 💎 2. Der SRE-Weg: Soft-serve (SSH Only)
#
# Für Puristen und extrem schnelle Workflows.
# - **Konzept:** Ein Git-Server ohne HTTP-Overhead. Alles läuft über SSH.
# - **Anwendung:** Ideal für die Synchronisation deiner \`mynixos-knowledge-base\` zwischen Server und Laptop.
# ─── End KB Nuggets ───

{ config, lib, ... }:
{
  options.my.forge.cockpit = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 9090; };
  };

  config = lib.mkIf config.my.forge.cockpit.enable {
    services.cockpit = {
      enable = true;
      port = config.my.forge.cockpit.port;
    };
  };
}
