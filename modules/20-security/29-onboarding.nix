# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-029"
# title: "Onboarding Status Flag"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-22
# tags: [security,onboarding,governance]
# description: "Simple onboarding flag and warning system to ensure production readiness. Emits a build warning when onboarding is incomplete (unless bastelmodus is active)."
# path: "modules/20-security/29-onboarding.nix"
# provides: [my.system.onboardingComplete]
# requires: []
# links:
#   module: modules/20-security/29-onboarding.nix
# source: mynixos-v5/modules/security/onboarding.nix
# ---
# ---ENDNIXMETA

{ config, lib, ... }:

{
  # ── Onboarding Status ──
  # Governance flag: warns when initial setup isn't verified.

  options.my.system.onboardingComplete = lib.mkOption {
    type = lib.types.bool;
    default = false;
    description = "Set to true after initial setup is verified. Emits a build warning when false (unless bastelmodus is active).";
  };

  config = {
    # ── Onboarding Warning ──
    warnings = lib.optional (
      !config.my.system.onboardingComplete
      && !(config.my.core.principles.bastelmodus or false)
    ) "⚠️ SYSTEM ONBOARDING INCOMPLETE: Set 'my.system.onboardingComplete = true' after verifying initial setup is production-ready.";
  };
}
