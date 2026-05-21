# ---NIXMETA---
# domain: XX-name
# id: NIXH-XX-SHORT
# status: draft # draft | active | deprecated
# provides:
# - my.services.NAME.enable
# requires:
# - 00-core
# - 10-network
# adr: ADR-XX-name.md
# guide: XX-name.md
# complexity: 2
# reviewed: YYYY-MM-DD
# ---ENDNIXMETA---

# ==============================================================================
# PURPOSE (one sentence, answers "what does this module do at runtime?")
# ==============================================================================
# Configures <service/subsystem> as the canonical <role> for this system.
# Key decisions → docs/adr/ADR-XX-name.md

{
 config,
 lib,
 pkgs,
 ...
}: let
 # --------------------------------------------------------------------------
 # MODULE CONFIG REF
 # Alias to the module's own option namespace. Avoids repeating
 # config.my.services.NAME throughout the file.
 # --------------------------------------------------------------------------
 cfg = config.my.services.NAME;

 # --------------------------------------------------------------------------
 # LOCAL CONSTANTS
 # Pure values only — no config references here.
 # If a value depends on config.*, it belongs in the config block below.
 # --------------------------------------------------------------------------
 # someConstant = "value";

in {
 # ============================================================================
 # OPTIONS
 # Declare the public interface this module exposes.
 # Keep options minimal — prefer conventions over configuration.
 # ============================================================================
 options.my.services.NAME = {
 enable = lib.mkEnableOption "short description of what this enables";

 # (anchor: NAME-options)
 # Add further options only if they genuinely vary between hosts/profiles.
 # Do not add options just to document internal values.
 };

 # ============================================================================
 # CONFIG
 # The implementation. Guarded by lib.mkIf cfg.enable.
 # ============================================================================
 config = lib.mkIf cfg.enable {

 # --------------------------------------------------------------------------
 # SYSTEMD SERVICE (if applicable)
 # --------------------------------------------------------------------------
 systemd.services.NAME = {
 description = "Short description";
 wantedBy = [ "multi-user.target" ];
 after = [ "network.target" ]; # be explicit, not just network-online

 # (anchor: NAME-service)
 serviceConfig = {
 # --- IDENTITY ---
 User = "NAME";
 Group = "NAME";

 # --- SANDBOXING (baseline — harden further per ADR-20-security) ---
 ProtectSystem = "strict";
 ProtectHome = true;
 PrivateTmp = true;
 PrivateDevices = true;
 NoNewPrivileges = true;
 MemoryDenyWriteExecute = true;

 # --- STATE ---
 # Prefer StateDirectory/CacheDirectory over hardcoded paths.
 StateDirectory = "NAME";

 # --- RESTART ---
 Restart = "on-failure";
 RestartSec = "5s";
 };
 };

 # --------------------------------------------------------------------------
 # USERS / GROUPS (if service runs under a dedicated user)
 # --------------------------------------------------------------------------
 # (anchor: NAME-users)
 users.users.NAME = {
 isSystemUser = true;
 group = "NAME";
 };
 users.groups.NAME = {};

 # --------------------------------------------------------------------------
 # PERSISTENCE (impermanence setup — paths that survive reboot)
 # --------------------------------------------------------------------------
 # (anchor: NAME-persistence)
 # environment.persistence."/persist".directories = [
 #   { directory = "/var/lib/NAME"; user = "NAME"; group = "NAME"; mode = "0750"; }
 # ];

 # --------------------------------------------------------------------------
 # PACKAGES (only what this module directly needs at runtime)
 # --------------------------------------------------------------------------
 # environment.systemPackages = [ pkgs.NAME ];

 };
}
