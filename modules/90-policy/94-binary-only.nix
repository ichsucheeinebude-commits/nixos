# ---NIXMETA
# ---
# domain: 90
# id: "NIXH-90-POL-004"
# title: "Binary-Only Policy"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [policy,nix,compilation,performance,binary-cache]
# description: "Enforces a strict download-only workflow by forbidding local compilation to protect system resources."
# path: "modules/90-policy/94-binary-only.nix"
# provides: [my.policy.binaryOnly]
# requires: [my.core.nix]
# links:
#   adr: docs/adr/ADR-90-policy.md
#   guide: docs/guides/90-policy.md
#   module: modules/90-policy/94-binary-only.nix
#   upstream: https://nixos.org/manual/nix/stable/command-ref/conf-file.html#conf-max-jobs
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Auf ressourcenbeschränkten Servern (z.B. 16GB RAM, schwache CPU) kann das
# lokale Kompilieren von Paketen das System lahmlegen. Die Binary-Only Policy
# zwingt Nix dazu, ausschließlich vorgebaute Binaries aus dem Cache zu laden.
#
# ### Entscheidung
#
# **Binary-Only Pattern:**
# 1.  **max-jobs = 0** — Keine lokalen Builds erlaubt.
# 2.  **Assertion** — Stellt sicher, dass max-jobs nicht versehentlich überschrieben wird.
# 3.  **Substituters** — Cachix oder nix-community als Fallback für Binaries.
#
# ### SRE-Standards
#
# - max-jobs = 0 bedeutet: Wenn kein Binary im Cache, build schlägt fehl.
# - Assertion gibt klare Fehlermeldung bei Policy-Verletzung.
# - Ausnahmen nur über `lib.mkForce` in Host-spezifischen Configs.
# ─── End KB Nuggets ───

{ config, lib, ... }:

{
  options.my.policy.binaryOnly = {
    enable = lib.mkEnableOption "Forbid local compilation, only use binary caches";
    substituters = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
      ];
      description = "Binary cache substituters to use.";
    };
    trustedPublicKeys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMRFGspBiTUi0="
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
      description = "Public keys for binary cache substituters.";
    };
  };

  config = lib.mkIf config.my.policy.binaryOnly.enable {
    # ── No Local Builds ──
    nix.settings.max-jobs = lib.mkForce 0;

    # ── Binary Cache Configuration ──
    nix.settings.substituters = lib.mkForce config.my.policy.binaryOnly.substituters;
    nix.settings.trusted-public-keys = lib.mkForce config.my.policy.binaryOnly.trustedPublicKeys;

    # ── Policy Enforcement ──
    assertions = [
      {
        assertion = config.nix.settings.max-jobs == 0;
        message = "🚫 [POLICY-VIOLATION] Local compilation is forbidden. Set max-jobs = 0.";
      }
    ];
  };
}
