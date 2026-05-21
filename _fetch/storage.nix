{ config, lib, pkgs, ... }:
let
  nms = { id = "NIXH-20-INF-005"; title = "Storage"; description = "mergerfs pool."; layer = 20; nixpkgs.category = "system/storage"; capabilities = [ "storage/mergerfs" ]; audit.last_reviewed = "2026-03-02"; audit.complexity = 3; };
  cfg = config.my.services.storagePool;
  srePaths = config.my.configs.paths;
in
{
  options.my.meta.storage = lib.mkOption { type = lib.types.attrs; default = nms; readOnly = true; };
  config = lib.mkIf cfg.enable {
    systemd.mounts = [
      { description = "Fast-Pool"; where = srePaths.storagePool; what = "/data/storage/b-on-a:/mnt/storage/ssd:/mnt/storage/hdd"; type = "fuse.mergerfs"; options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=20G,fsname=fast-pool"; wantedBy = [ "multi-user.target" ]; }
      { description = "Media-Pool"; where = srePaths.mediaLibrary; what = "/mnt/storage/ssd:/mnt/storage/hdd"; type = "fuse.mergerfs"; options = "allow_other,use_ino,cache.readdir=true,dropcacheonclose=true,category.create=ff,minfreespace=50G,fsname=media-pool"; wantedBy = [ "multi-user.target" ]; }
    ];
    systemd.services.nixhome-path-enforcement = {
      description = "NixHome Path Enforcement"; wantedBy = [ "multi-user.target" ]; serviceConfig.Type = "oneshot";
      script = "mkdir -p ${srePaths.storagePool}/downloads; mkdir -p ${srePaths.mediaLibrary}; chown -R root:media ${srePaths.storagePool}/downloads ${srePaths.mediaLibrary};";
    };
    environment.systemPackages = with pkgs; [ mergerfs util-linux ];
  };
}
