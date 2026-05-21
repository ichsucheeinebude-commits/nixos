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

{ config, lib, pkgs, ... }:
let
 cfg = config.my.storage.deferred;
 srePaths = config.my.configs.paths;

 processScript = pkgs.writeShellScript "process-delete-queue" ''
 set -euo pipefail

 QUEUE_DIR="${cfg.queueDir}"
 MAX_AGE_DAYS=${toString cfg.maxAgeDays}
 HDD_POOL="${srePaths.tierC}"
 PHYSICAL_HDDS=(${lib.concatStringsSep " " config.my.storage.devices})

 echo "--- 🗑️ Starting Deferred Deletion Processor ---"
 
 # Ensure queue dir exists
 mkdir -p "$QUEUE_DIR"

 ANY_ACTIVE=false
 for dev in "''${PHYSICAL_HDDS[@]}"; do
   if ${pkgs.hdparm}/bin/hdparm -C "$dev" 2>/dev/null | grep -q "active/idle"; then
     ANY_ACTIVE=true
     break
   fi
 done

 echo "📈 Pool Status: ANY_ACTIVE=$ANY_ACTIVE"

 # 🚀 EARLY EXIT: If HDD is asleep, check if we MUST delete anything
 if [ "$ANY_ACTIVE" = false ]; then
   # Check if any file in the queue is older than MAX_AGE_DAYS
   # Using find to get the age of the oldest file
   OLDEST_AGE=$(${pkgs.findutils}/bin/find "$QUEUE_DIR" -type f -printf '%T@\n' | sort -n | head -1 || echo "")
   if [ -n "$OLDEST_AGE" ]; then
     MAX_AGE_SECONDS=$((MAX_AGE_DAYS * 86400))
     CURRENT_TIME=$(date +%s)
     OLDEST_AGE_INT=''${OLDEST_AGE%.*}
     if [ $((CURRENT_TIME - OLDEST_AGE_INT)) -lt "$MAX_AGE_SECONDS" ]; then
       echo "😴 HDD is standby and no entries exceed MAX_AGE_DAYS ($MAX_AGE_DAYS). Early exit."
       exit 0
     fi
   else
     echo "ℹ️ Queue is empty. Nothing to do."
     exit 0
   fi
 fi

 # Process queue
 shopt -s nullglob
 for ENTRY in "$QUEUE_DIR"/*; do
   [ -f "$ENTRY" ] || continue
   # Guard against empty entries
   [ -s "$ENTRY" ] || { rm -f -- "$ENTRY"; continue; }
 
   FILE_AGE_SECONDS=$(($(date +%s) - $(stat -c %Y "$ENTRY")))
   MAX_AGE_SECONDS=$((MAX_AGE_DAYS * 86400))
 
   SHOULD_DELETE=false
   if [ "$ANY_ACTIVE" = true ]; then
     SHOULD_DELETE=true
   elif [ "$FILE_AGE_SECONDS" -gt "$MAX_AGE_SECONDS" ]; then
     SHOULD_DELETE=true
     echo "⏰ Forcing deletion of $ENTRY due to age ($MAX_AGE_DAYS days)"
   fi
 
   if [ "$SHOULD_DELETE" = true ]; then
     TARGET_PATH=$(cat -- "$ENTRY")
     if [ -n "$TARGET_PATH" ] && [ -e "$TARGET_PATH" ]; then
       # 🛡️ PATH VALIDATION (M-02 Defense)
       REAL_TARGET=$(readlink -f -- "$TARGET_PATH" || echo "$TARGET_PATH")
       if [[ "$REAL_TARGET" == "$HDD_POOL"* ]]; then
         echo "🗑️ Safely deleting: $REAL_TARGET"
         rm -rf -- "$REAL_TARGET"
       else
         echo "🛑 SECURITY ALERT: Attempted out-of-bounds deletion! Target: $REAL_TARGET"
         exit 1
       fi
     else
       echo "❓ Target path '$TARGET_PATH' not found or empty, skipping."
     fi
     rm -f -- "$ENTRY"
   else
     echo "😴 Skipping $ENTRY (HDD is standby and file is not old enough)"
   fi
 done

 echo "--- ✅ Deferred Deletion Finished ---"
 '';
in
{
 options.my.storage.deferred = {
 enable = lib.mkEnableOption "Deferred Deletion Queue to save HDD spin-ups";
 queueDir = lib.mkOption {
 type = lib.types.str;
 default = "${srePaths.tierB}/delete_queue";
 description = "Directory on SSD where paths to be deleted are stored";
 };
 maxAgeDays = lib.mkOption {
 type = lib.types.int;
 default = 7;
 description = "Force delete if entry is older than this many days, even if HDD is asleep";
 };
 };

 config = lib.mkIf cfg.enable {
 systemd.services.process-delete-queue = {
 description = "Process Deferred Deletion Queue";
 serviceConfig = {
 Type = "oneshot";
 ExecStart = processScript;
 User = "root";
 Nice = 19;
 IOSchedulingClass = "idle";
 
 # 🛡️ Sandboxing (LHF-07)
 NoNewPrivileges = true;
 PrivateTmp = true;
 ProtectSystem = "strict";
 ReadWritePaths = [ 
   config.my.configs.paths.tierC 
   cfg.queueDir 
 ];
 InaccessiblePaths = [ "/home" "/etc/ssh" "/persist/etc/ssh" ];
 };
 };

 systemd.timers.process-delete-queue = {
 description = "Hourly processing of deferred deletion queue";
 wantedBy = [ "timers.target" ];
 timerConfig = {
 OnCalendar = "hourly";
 Persistent = true;
 };
 };

 systemd.tmpfiles.rules = [
 "d ${cfg.queueDir} 0755 root root -"
 ];
 };
}
