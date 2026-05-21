# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SSC-001"
# title: "Secrets Schema"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [sops, schema]
# description: "Secrets Schema module."
# path: "modules/20-security/23-secrets-schema.nix"
# provides: [my.security.secrets_schema]
# requires: [20-security/22-secrets]
# links:
#   adr: docs/adr/ADR-20-secrets-schema.md
#   guide: docs/guides/20-secrets-schema.md
#   module: modules/20-security/23-secrets-schema.nix
# ---
# ---ENDNIXMETA

# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-SCH-001",
#   "title": "SOPS Secret Schema",
#   "layer": 0,
#   "category": "core/security",
#   "lastReviewed": "2026-05-14",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["secrets", "schema", "security"],
#   "description": "Hardened schema defining the immutable list of allowed SOPS secret keys."
# }
# ---ENDNIXMETA

{ lib, config, ... }:

let
  inherit (lib) mkOption types;

  # 🔐 THE CATEGORIZED KEY LIST
  # Secrets are split into files to minimize blast radius (Decision SEC-005)
  categories = {
    infra = [
      "user_password"
      "freund_password"
      "cloudflare_token"
      "github_token"
      "wireguard_admin_private_key"
      "restic_password"
      "backblaze_access_key"
      "backblaze_secret_key"
    ];
    
    media = [
      "paperless_secret_key"
      "vaultwarden_env"
      "miniflux_admin_password"
      "readeck_env"
      "linkwarden_env"
      "n8n_enc_key"
      "sonarr_api_key"
      "radarr_api_key"
      "readarr_api_key"
    ];
  };

  # Flattened list for the schema option
  schema = lib.genAttrs (categories.infra ++ categories.media) (name: "");

in {
  options.my.meta.secrets_schema = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  options.my.secrets = {
    schema = mkOption {
      type = types.attrsOf types.str;
      default = schema;
      readOnly = true;
      description = "Hardened schema for allowed SOPS secret keys.";
    };
    categories = mkOption {
      type = types.attrsOf (types.listOf types.str);
      default = categories;
      readOnly = true;
      description = "Categorized secret keys for file mapping.";
    };
  };

  config = {
    # 🔍 AUDIT WARNING
    # Emits a warning if a secret is defined in SOPS that is not in our schema.
    # Note: We check if any defined secret name is NOT a key in our schema.
    warnings = let
      definedKeys = lib.attrNames config.sops.secrets;
      allowedKeys = lib.attrNames config.my.secrets.schema;
      unknownKeys = lib.filter (k: !lib.elem k allowedKeys) definedKeys;
    in lib.optional (unknownKeys != []) 
      "⚠️ [SEC-SCHEMA] Unknown keys found in sops.secrets: ${lib.concatStringsSep ", " unknownKeys}. Please register them in secrets-schema.nix.";
    };
    }
    
