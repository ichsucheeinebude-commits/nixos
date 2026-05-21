{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-015";
    title = "Host Q958 Hardware Profile";
    description = "Specific hardware optimizations for Fujitsu Q958 (i3-9100 / UHD 630) including GuC/HuC and QSV.";
    layer = 00;
    nixpkgs.category = "hardware/graphics";
    capabilities = ["gpu/intel-qsv" "hardware/firmware" "power/management"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  cfg = config.my.profiles.hardware.q958;
in {
  options.my.meta.host_q958_hardware_profile = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for host-q958-hardware-profile module";
  };

  config = lib.mkIf cfg.enable {
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
    hardware.firmware = [pkgs.linux-firmware];

    # 🏎️ INTEL GPU OPTIMIZATION (Nixpkgs Hardware Standard)
    boot.kernelParams = [
      "i915.enable_guc=3" # 💎 Update auf v3 für i3-9100
      "i915.enable_fbc=1"
      "i915.enable_psr=1"
    ];
    boot.kernelModules = ["i915"];

    hardware.graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver # VA-API
        intel-compute-runtime # OpenCL
        vpl-gpu-rt # OneVPL
        libvdpau-va-gl # VDPAU Bridge
      ];
    };

    environment.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
    environment.systemPackages = with pkgs; [
      libva-utils
      intel-gpu-tools
      vulkan-tools
    ];

    users.users.${config.my.configs.identity.user}.extraGroups = ["video" "render"];
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:3320a25690cd5a9c3b6155791edf76fc573f3b3d07273af97f4a0077772ba350
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

