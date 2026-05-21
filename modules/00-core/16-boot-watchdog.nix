# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-016"
# title: "Boot Health Watchdog"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [core,boot,health-check,watchdog]
# description: "Post-boot health check service that verifies critical services (Caddy, Pocket-ID, PostgreSQL) and persistence state after multi-user.target."
# path: "modules/00-core/16-boot-watchdog.nix"
# provides: [my.core.boot-watchdog]
# requires: [00-core]
# links:
#   module: modules/00-core/16-boot-watchdog.nix
# source: mynixos-v5/modules/core/boot-watchdog.nix
# ---
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:

{
  # ── Post-Boot Health Watchdog ──
  # Runs after multi-user.target to verify system health.
  # Checks: Caddy, Pocket-ID, PostgreSQL, persistence state.

  options.my.core.boot-watchdog = {
    enable = lib.mkEnableOption "Post-boot health watchdog";
  };

  config = lib.mkIf config.my.core.boot-watchdog.enable {
    systemd.services.boot-watchdog = {
      description = "Strict Boot Health Check";
      after = [ "multi-user.target" "caddy.service" "pocket-id.service" "postgresql.service" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ProtectSystem = "strict";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };

      script = let
        stateDir = config.my.core.paths.stateDir or "/data/state";
        pocketIdPort = config.my.ports.pocketId or 10010;
      in ''
        set -e
        echo "🧐 Starting System Health Audit..."

        # 1. Caddy Check
        ${pkgs.systemd}/bin/systemctl is-active --quiet caddy
        ${pkgs.curl}/bin/curl --unix-socket /run/caddy/admin.sock -sf http://localhost/config/ > /dev/null
        echo "✅ Caddy: ACTIVE & SECURE"

        # 2. Pocket-ID Check
        ${pkgs.systemd}/bin/systemctl is-active --quiet pocket-id
        ${pkgs.curl}/bin/curl -sf http://127.0.0.1:${toString pocketIdPort}/ > /dev/null
        echo "✅ Pocket-ID: ACTIVE"

        # 3. PostgreSQL Check
        ${pkgs.systemd}/bin/systemctl is-active --quiet postgresql
        echo "✅ PostgreSQL: ACTIVE"

        # 4. Persistence Check
        if [ ! -d "${stateDir}/caddy" ]; then
          echo "❌ PERSISTENCE FAILURE: Caddy state missing!"
          exit 1
        fi
        echo "✅ Persistence: VERIFIED"

        # 🔐 TPM INTEGRITY CHECK (optional, uncomment after first boot with TPM enrollment)
        # GOLDEN_PCR0="<expected_hash>"
        # CURRENT_PCR0=$(${pkgs.tpm2-tss}/bin/tpm2_pcrread sha256:0 | ${pkgs.gnugrep}/bin/grep -oP 'sha256\s+:\s+\K[a-f0-9]+')
        # if [ "$CURRENT_PCR0" != "$GOLDEN_PCR0" ]; then
        #   echo "❌ TPM PCR0 MISMATCH: Firmware tampering detected!"
        #   exit 1
        # fi

        echo "🚀 SYSTEM STATUS: STABLE - ALL SYSTEMS GO"
      '';
    };
  };
}
