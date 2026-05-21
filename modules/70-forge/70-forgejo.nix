# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FRG-001"
# title: "Forgejo Git"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [forge,forgejo,git]
# description: "Forgejo self-hosted Git service."
# path: "modules/70-forge/70-forgejo.nix"
# provides: [my.forge.forgejo]
# requires: []
# links:
#   adr: docs/adr/ADR-70-forge.md
#   guide: docs/guides/70-forge.md
#   module: modules/70-forge/70-forgejo.nix
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
  options.my.forge.forgejo = {
    enable = lib.mkOption { type = lib.types.bool; default = false; };
    port = lib.mkOption { type = lib.types.port; default = 3000; };
    disableRegistration = lib.mkOption { type = lib.types.bool; default = true; };
  };

  config = lib.mkIf config.my.forge.forgejo.enable {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = config.my.forge.forgejo.port;
        };
        service.DISABLE_REGISTRATION = config.my.forge.forgejo.disableRegistration;
      };
    };
  };
}
