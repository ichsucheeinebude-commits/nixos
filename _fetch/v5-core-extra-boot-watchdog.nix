# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-AUTO-GEN",
#   "title": "Auto Generated",
#   "layer": 99,
#   "category": "auto/gen",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["auto-generated"],
#   "description": "Auto-migrated module to NIXMETA 2.0."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }: {
  # 🚀 HARDENED BOOT WATCHDOG
  # Runs after multi-user.target to verify system health.

  systemd.services.boot-watchdog = {
    description = "v7.0 Strict Boot Health Check";
    after = [ "multi-user.target" "caddy.service" "pocket-id.service" "postgresql.service" ];
    wantedBy = [ "multi-user.target" ];
    
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "boot-check" ''
        set -e
        echo "🧐 Starting System Health Audit..."
        
        # 1. Caddy Check
        systemctl is-active --quiet caddy
        curl --unix-socket /run/caddy/admin.sock -sf http://localhost/config/ > /dev/null
        echo "✅ Caddy: ACTIVE & SECURE"
        
        # 2. Pocket-ID Check
        # LHF-06: Using SSoT port from registry
        systemctl is-active --quiet pocket-id
        curl -sf http://127.0.0.1:${toString config.my.services.spec.pocket-id.port}/ > /dev/null
        echo "✅ Pocket-ID: ACTIVE"
        
        # 3. PostgreSQL Check
        systemctl is-active --quiet postgresql
        echo "✅ PostgreSQL: ACTIVE"
        
        # 4. Persistence Check
        if [ ! -d "${config.my.configs.paths.stateDir}/caddy" ]; then
          echo "❌ PERSISTENCE FAILURE: Caddy state missing!"
          exit 1
        fi
        echo "✅ Persistence: VERIFIED"
        
        # 🔐 TPM INTEGRITY CHECK (v6.2)
        # Activate after first successful boot with TPM enrollment:
        # GOLDEN_PCR0="<expected_hash>"
        # GOLDEN_PCR1="<expected_hash>"
        # GOLDEN_PCR7="<expected_hash>"
        # CURRENT_PCR0=$(tpm2_pcrread sha256:0 | cut -d' ' -f2)
        # if [ "$CURRENT_PCR0" != "$GOLDEN_PCR0" ]; then
        #   echo "❌ TPM PCR0 MISMATCH: Firmware tampering detected!"
        #   exit 1
        # fi
        
        echo "🚀 SYSTEM STATUS: STABLE - ALL SYSTEMS GO"
      '';
    };
  };
}
