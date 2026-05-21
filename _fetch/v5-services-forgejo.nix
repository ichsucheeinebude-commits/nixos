# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-SRV-GIT-001",
#   "title": "Forgejo Sovereign Git",
#   "layer": 30,
#   "category": "services/git",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 3,
#   "tags": ["git", "forgejo", "sovereignty", "hardened"],
#   "description": "Hardened Forgejo instance for self-hosted git. Uses SQLite3 for efficiency."
# }
# ---ENDNIXMETA

{ config, lib, pkgs, ... }:
let
  name = "forgejo";
  cfg = config.my.services.forgejo;
in {
  options.my.services.forgejo = {
    enable = lib.mkEnableOption "Forgejo Sovereign Git";
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    (config.myLib.mkService {
      inherit config name;
      description = "Forgejo Git Service (Hardened)";
      port = config.my.ports.forgejo;
      # Forgejo needs some write access to its data directory which mkService provides.
      # We use SQLite3 to keep it lean.
    })
    {
      services.forgejo = {
        enable = true;
        database.type = "sqlite3";
        settings = {
          server = {
            DOMAIN = "git.${config.my.configs.identity.domain}";
            HTTP_ADDR = "127.0.0.1";
            HTTP_PORT = config.my.ports.forgejo;
            ROOT_URL = "https://git.${config.my.configs.identity.domain}/";
          };
          service.DISABLE_REGISTRATION = true;
          session.COOKIE_SECURE = true;
        };
        dump.enable = true;
      };

      # 🛡️ Additional Hardening for Forgejo
      systemd.services.forgejo.serviceConfig = {
        MemoryMax = "1G";
        MemoryHigh = "800M";
      };
    }
  ]);
}
