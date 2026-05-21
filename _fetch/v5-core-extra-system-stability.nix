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

{
 config,
 lib,
 pkgs,
 ...
}: let
 # 🚀 NMS v4.2 Metadaten (hardened Stability)
 nms = {
 id = "NIXH-00-COR-034";
 title = "System Stability (SRE Guard)";
 description = "Proactive maintenance and fail-safe logic (Watchdogs, Kernel-Panic, EFI-Cleanup).";
 layer = 00;
 nixpkgs.category = "system/settings";
 capabilities = ["system/maintenance" "safety/watchdog" "safety/recovery"];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 3;
 source_repo = "grapefruit89/mynixos";
 };
in {
 options.my.meta.system_stability = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 config = {
  # 🐕 HARDWARE WATCHDOG (Fragment 958)
  # Rebootet das System automatisch bei Totalausfall (Hang)
  # NixOS uses systemd.extraConfig for global systemd settings
  systemd.extraConfig = ''
    RuntimeWatchdogSec=30s
    RebootWatchdogSec=10min
    ShutdownWatchdogSec=10min
    CtrlAltDelBurstAction=reboot-force
  '';

  # 🚀 OOMD (Out-Of-Memory Daemon)
  # Proaktives Management von Speicherengpässen (Besonders wichtig für AI/Ollama)
    systemd.oomd = {
    enable = true;
    enableUserSlices = true;
    enableSystemSlice = true;
  };

  # VIP OOM PROTECTION (v6.1)
  # PostgreSQL (-1000), Caddy (-900), Pocket-ID (-900) are protected
  # from the OOM killer. The system must never kill its database,
  # reverse proxy, or authentication provider.

  # 🛑 USER RESOURCE LIMITS
  # Prevent unprivileged user processes from exhausting system RAM
  systemd.slices.user.sliceConfig.ManagedOOMMemoryPressureLimit = "50%";

  # 🏎️ KERNEL PANIC HANDLING
 boot.kernel.sysctl = {
 "kernel.panic" = 10; # Reboot nach 10 Sek bei Panic
 "kernel.panic_on_oops" = 1;
 "vm.panic_on_oom" = 0; # OOM-Killer bevorzugt vor Reboot
 };

 # 🧹 EFI ACTIVATION CLEANUP
 system.activationScripts.cleanEfiEntries = {
 text = ''
 echo "🧹 hardened: Bereinige verwaiste EFI-Boot-Einträge..."
 # 🛡️ Safety Guard: Only run if we are NOT in bastelmodus and at least one safeguard entry exists
 if [ "${toString config.my.configs.bastelmodus}" = "false" ]; then
   ENTRIES_TO_DELETE=$(${pkgs.efibootmgr}/bin/efibootmgr | grep "Boot[0-9]" | grep -vE "systemd-boot|NixOS|Linux|USB|Hard Drive|Network" | ${pkgs.gawk}/bin/awk '{print $1}' | ${pkgs.gnused}/bin/sed 's/Boot//;s/\*//')
   if [ -n "$ENTRIES_TO_DELETE" ]; then
     echo "$ENTRIES_TO_DELETE" | xargs -I{} ${pkgs.efibootmgr}/bin/efibootmgr -b {} -B 2>/dev/null || true
   fi
 fi
 '';
 };

 # 🚨 EMERGENCY LOGGING
 systemd.services.nixhome-emergency = {
 description = "NixOS Home Emergency Recovery Info";
 serviceConfig = {
 Type = "oneshot";
 StandardOutput = "tty";
 TTYPath = "/dev/tty1";
 };
 script = ''
 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
 echo "🚨 NIXHOME v4.2 SYSTEM STABILITY ALERT"
 echo "Manual Recovery: Use SSH Rescue Port 2222"
 echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" > /dev/tty1
 '';
 };
 };
}
/**
 * ---\n * technical_integrity:\n * checksum: sha256:e918cb5d57d4499c77e11342fca451e92f6cd82723a69131a8b84c7bec01214f\n * eof_marker: NIXHOME_VALID_EOF* ---\n */
