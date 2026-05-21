# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-001"
# title: "SOPS Secrets Management"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [sops, secrets]
# description: "SOPS Secrets Management module."
# path: "modules/20-security/22-secrets.nix"
# provides: [my.security.secrets]
# requires: [20-security/21-kernel-hardening]
# links:
#   adr: docs/adr/ADR-20-secrets.md
#   guide: docs/guides/20-secrets.md
#   module: modules/20-security/22-secrets.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-SEC-001",
#   "title": "Secrets Master Vault",
#   "layer": 0,
#   "category": "core/security",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["secrets", "sops", "security"],
#   "description": "Centralized secret management with multi-key age/SSH encryption."
# }
# ---ENDNIXMETA

{
 config,
 lib,
 pkgs,
 ...
}:
let
  in
{
  options.my.meta.secrets = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

# 🛡️ SOPS MULTI-KEY STRATEGY (Decision S-01)
# Secrets are encrypted for three independent keys. Any one can decrypt.
#  - Key 1: Server SSH Host Key (age-ssh-ed25519) – present on /persist
#  - Key 2: Admin Age Key – stored on admin workstation, NEVER on server
#  - Key 3: Recovery Age Key – stored offline (USB in safe, paper)
#
# RECOVERY: If host key is lost:
#  1. Boot recovery medium
#  2. Use admin/recovery key to decrypt secrets.yaml
#  3. Restore /persist from restic
#  4. Run nixos-rebuild switch
let
 # 🗺️ SSoT: Schema to SOPS Transformation
 # Derives sops.secrets entries from the read-only schema.
 infraKeys = config.my.secrets.categories.infra;
 mediaKeys = config.my.secrets.categories.media;

 sopsEntries = lib.genAttrs (infraKeys ++ mediaKeys) (name: {
   # Passwords need users access
   neededForUsers = lib.hasSuffix "_password" name;
   # Assign to correct file based on category
   sopsFile = if lib.elem name infraKeys 
              then ../../secrets/infra.yaml 
              else ../../secrets/media.yaml;
 });
in {
 # 🔐 SOPS GLOBAL CONFIG
 sops = {
   # defaultSopsFile is now deprecated by explicit sopsFile per secret
   # but kept as fallback for unknown keys
   defaultSopsFile = ../../secrets/secrets.yaml;
   age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
   secrets = sopsEntries;
 };

 # 🛡️ SECRETS ENGINE (Zero-Trust Logic)
 config = {
    # 🔐 EMERGENCY KEY SYNC (KRIT-02: Encrypted via age)
    systemd.services.sops-key-overlay = {
      description = "Encrypted SSH Host Key Overlay for SOPS Decryption";
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        # 🛡️ SANDBOXING
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        NoNewPrivileges = true;
        ReadWritePaths = [ config.my.configs.paths.tierB ];
      };
      script = ''
        KEY="/persist/etc/ssh/ssh_host_ed25519_key"
        DEST="${config.my.configs.paths.tierB}/secrets/emergency_age_key.age"
        
        if [ -f "$KEY" ]; then
          mkdir -p "$(dirname "$DEST")"
          # Recipient ableiten (SSH Public Key → Age Recipient)
          PUB_KEY=$(${pkgs.openssh}/bin/ssh-keygen -y -f "$KEY")
          RECIPIENT=$(echo "$PUB_KEY" | ${pkgs.ssh-to-age}/bin/ssh-to-age)
          
          # Verschlüsseln
          ${pkgs.age}/bin/age -r "$RECIPIENT" -o "$DEST" < "$KEY"
          chmod 600 "$DEST"
          logger -t sops-sync "Backup of SSH host key (Encrypted via age) successful."
        fi
      '';
    };

    systemd.services.sops-recovery-validation = {
      description = "Weekly SOPS Recovery Validation";
      after = [ "network.target" ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${pkgs.sops}/bin/sops --decrypt ${config.sops.secrets.sops-recovery-test.sopsFile} > /dev/null";
        ProtectSystem = "strict";
        PrivateTmp = true;
        NoNewPrivileges = true;
      };
    };

    systemd.timers.sops-recovery-validation = {
      description = "Weekly SOPS Recovery Validation Timer";
      timerConfig = { OnCalendar = "weekly"; Persistent = true; };
      wantedBy = [ "timers.target" ];
    };
 };
}
