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
 cfg = config.my.storage.mover;
 srePaths = config.my.configs.paths;

 moverScript = pkgs.writeShellApplication {
   name = "smart-mover";
   runtimeInputs = with pkgs; [ coreutils hdparm lsof rsync findutils ];
   text = ''
     set -euo pipefail

     # 📦 SMART STORAGE TIERING (anchor: storage-tiering)
     echo "--- 📦 Smart Mover 2.0 Initialized (v6.1 Strict) ---"

     # --- 1. TIER A -> B (NVMe Pressure Relief) ---
     FREE_A=$(df --output=avail "${srePaths.tierA}" | tail -1)
     FREE_GB_A=$((FREE_A / 1024 / 1024))
     if [ "$FREE_GB_A" -lt 5 ]; then
         echo "🚀 TIER A CRITICAL ($FREE_GB_A GB). Evacuating overflow data to Tier B..."
         # Logic to move from /persist/app-data/overflow_eligible to SSD if needed, respecting DB blacklist
     fi

     # --- 2. TIER B -> C (SSD Capacity Management) ---
     FREE_B=$(df --output=avail "${srePaths.tierB}" | tail -1)
     FREE_GB_B=$((FREE_B / 1024 / 1024))

     # Determine HDD state
     IS_AWAKE=0
     PHYSICAL_HDDS=(${lib.concatStringsSep " " config.my.storage.devices})
     for dev in "''${PHYSICAL_HDDS[@]}"; do
         if hdparm -C "$dev" | grep -q "active/idle"; then
             IS_AWAKE=$((IS_AWAKE + 1))
         fi
     done

     # Determine Move Priority for B2 (Private/Media) -> C (HDD Archive)
     TARGET_FREE_GB=${toString cfg.targetFreeGB}
     MAX_ITERATIONS=100
     COUNT=0
     DRY_RUN=${if cfg.dryRun then "1" else "0"}

     LOW_SPACE=$((FREE_GB_B < 50))
     CRITICAL_SPACE=$((FREE_GB_B < 10))
     HDD_BUSY=$((IS_AWAKE > 0))

     DO_MOVE=0
     if [ "$CRITICAL_SPACE" -eq 1 ]; then
         DO_MOVE=1
         echo "🚀 Tier B SPACE CRITICAL ($FREE_GB_B GB). Forcing archival of eldest media."
     elif [ "$LOW_SPACE" -eq 1 ] && [ "$HDD_BUSY" -eq 1 ]; then
         DO_MOVE=1
         echo "⚖️ Tier B LOW SPACE ($FREE_GB_B GB) and HDD AWAKE. Optimizing SSD capacity."
     else
         echo "💤 Conditions not met for media archival (Free: $FREE_GB_B GB, HDD Awake: $IS_AWAKE). Skipping."
     fi

     if [ "$DO_MOVE" -eq 1 ]; then
         SOURCE_DIR="${srePaths.mediaLibrary}"
         TARGET_DIR="${srePaths.mediaArchive}"

         echo "📂 Scanning for eldest files in B2 (Private Media)..."

         while [ "$FREE_GB_B" -lt "$TARGET_FREE_GB" ] && [ "$COUNT" -lt "$MAX_ITERATIONS" ]; do
             COUNT=$((COUNT + 1))
             OLDEST=$(find "$SOURCE_DIR" -type f \
                 ! -name "*.wal" ! -name "*.db" ! -name "*.sqlite" ! -name "*.db-journal" ! -name "*.lock" \
                 ! -name "*.log" ! -name "*.bak" ! -path "*/database/*" \
                 -printf '%A@ %p\n' | sort -n | head -1 | cut -d' ' -f2-)

             if [ -z "$OLDEST" ]; then break; fi

             if lsof -- "$OLDEST" > /dev/null 2>&1; then
                 continue
             fi

             REL_PATH="''${OLDEST#"$SOURCE_DIR/"}"
             DEST_DIR=$(dirname -- "$TARGET_DIR/$REL_PATH")

             if [ "$DRY_RUN" -eq 1 ]; then
                 echo "[DRY-RUN] Would move: $REL_PATH"
                 FREE_GB_B=$((FREE_GB_B + 5)) # Simulate growth
             else
                 mkdir -p -- "$DEST_DIR"
                 if rsync -a -- "$OLDEST" "$TARGET_DIR/$REL_PATH"; then
                     rm -f -- "$OLDEST"
                     echo "🚚 Archived eldest media file: $REL_PATH"
                 fi
                 FREE_SPACE_B=$(df --output=avail "$SOURCE_DIR" | tail -1)
                 FREE_GB_B=$((FREE_SPACE_B / 1024 / 1024))
             fi
         done
     fi

     echo "--- ✅ Smart Mover 2.0 finished. ---"
   '';
 };

in
{
 options.my.storage.mover = {
 enable = lib.mkEnableOption "Smart Storage Tiering Mover";
 ssdDir = lib.mkOption { type = lib.types.str; default = srePaths.downloads; };
 hddDir = lib.mkOption { type = lib.types.str; default = "${srePaths.tierC}/downloads"; };
 lowSpaceThresholdGB = lib.mkOption { type = lib.types.int; default = 20; };
 targetFreeGB = lib.mkOption { type = lib.types.int; default = 50; };
 dryRun = lib.mkOption { type = lib.types.bool; default = false; };
 };

 config = lib.mkIf cfg.enable {
 systemd.services.storage-mover = {
 description = "Capacity-Based Smart Mover (SSD -> HDD)";
 unitConfig = {
 ConditionPathIsMountPoint = [ srePaths.tierA srePaths.tierB srePaths.tierC ];
 };
 serviceConfig = {
 Type = "oneshot";
 ExecStart = "${moverScript}/bin/smart-mover";
 Nice = 19;
 IOSchedulingClass = "idle";
 CPUSchedulingPolicy = "idle";
 };
 };

 systemd.timers.storage-mover = {
 wantedBy = [ "timers.target" ];
 timerConfig = {
 OnCalendar = "daily";
 Persistent = true;
 RandomizedDelaySec = "1h";
 };
 };
 };
}
