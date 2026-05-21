# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-POL-003"
# title: "Security Assertions"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [policy,enforcement,security,assertions,hardening]
# description: "Global security assertions to ensure critical hardening settings are active in production. Bypassed in development mode."
# path: "modules/90-policy/93-security-assertions.nix"
# provides: [my.policy.securityAssertions]
# requires: [my.network.firewall, my.network.ssh, my.core.bastelmodus]
# links:
#   adr: docs/adr/ADR-93-security-assertions.md
#   guide: docs/guides/93-security-assertions.md
#   module: modules/90-policy/93-security-assertions.nix
#   upstream: https://nixos.org/manual/nixos/stable/#opt-assertions
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# In NixOS kann es vorkommen, dass Module sich gegenseitig überschreiben und
# kritische Security-Einstellungen unbemerkt deaktiviert werden. Assertions
# bieten eine Fail-Safe-Mechanik: Wenn eine kritische Annahme nicht erfüllt
# ist, bricht die Evaluation ab — kein deployen mit schwacher Security.
#
# ### Entscheidung
#
# **Security Assertions Pattern:**
# 1.  **Helper-Funktion `must`** — Kurze Syntax für assertion + message.
# 2.  **Bastelmodus-Bypass** — Im Entwicklungsmodus werden Assertions übersprungen.
# 3.  **Kritische Checks:**
#     - SEC-NET-001: Firewall muss aktiv sein.
#     - SEC-NET-002: NFTables muss aktiv sein.
#     - SEC-SSH-002: Root-Login via SSH muss verboten sein.
#
# ### SRE-Standards
#
# - Assertions sind NixOS-native (`config.assertions`).
# - Bastelmodus ist ein bewusster Bypass, kein Security-Hole.
# - Jeder Check hat eine eindeutige ID für Audit-Zwecke.
# ─── End KB Nuggets ───

{ config, lib, ... }:

let
  bastelmodus = config.my.core.bastelmodus or false;

  # ── Helper: Kurzschreibweise für Assertions ──
  must = assertion: message: { inherit assertion message; };

  sshSettings = config.services.openssh.settings;
in
{
  options.my.policy.securityAssertions = {
    enable = lib.mkEnableOption "Security assertion enforcement";
  };

  config = lib.mkIf config.my.policy.securityAssertions.enable {
    config.assertions = lib.optionals (!bastelmodus) [
      # ── Network Security ──
      (must (config.networking.firewall.enable == true)
        "[SEC-NET-001] Firewall must be enabled.")
      (must (config.networking.nftables.enable == true)
        "[SEC-NET-002] NFTables must be enabled.")

      # ── SSH Security ──
      (must (sshSettings.PermitRootLogin == "no")
        "[SEC-SSH-002] PermitRootLogin must be 'no'.")
    ];
  };
}
