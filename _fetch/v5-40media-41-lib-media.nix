# modules/40-media/41-lib-media.nix
#
# Shared factories and helpers for Domain 40 (Media Stack).
# Imported by 42-arr-stack.nix, 43-download.nix, etc.
# Do NOT import this file from outside modules/40-media/.
{ config, lib, pkgs, myLib, ... }:

let
  # ---------------------------------------------------------------------------
  # mkArr – factory for *Arr services (Radarr, Sonarr, Prowlarr, Lidarr, Readarr)
  # ---------------------------------------------------------------------------
  mkArr = { name, port, mediaSubdir ? name, extraServiceCfg ? {} }:
    lib.recursiveUpdate
      (myLib.mkService name {
        inherit port;
        stateDir = "/var/lib/${name}";
        serviceConfig = {
          NoNewPrivileges    = true;
          PrivateTmp         = true;
          ProtectSystem      = "strict";
          ReadWritePaths     = [ "/var/lib/${name}" "/mnt/media/${mediaSubdir}" ];
        };
      })
      extraServiceCfg;

  # ---------------------------------------------------------------------------
  # mkStreamingService – factory for media-serving daemons (Jellyfin, etc.)
  # ---------------------------------------------------------------------------
  mkStreamingService = { name, port, extraServiceCfg ? {} }:
    lib.recursiveUpdate
      (myLib.mkService name {
        inherit port;
        stateDir = "/var/lib/${name}";
        serviceConfig = {
          NoNewPrivileges = true;
          PrivateTmp      = true;
          DeviceAllow     = [ "char-render" "char-drm" ];
          ReadWritePaths  = [
            "/var/lib/${name}"
            "/var/cache/${name}"
            "/dev/dri"
          ];
        };
      })
      extraServiceCfg;

  # ---------------------------------------------------------------------------
  # Standard Newznab category sets
  # ---------------------------------------------------------------------------
  newznabCategories = {
    movies = [ 2000 2010 2020 2030 2040 2050 ];
    tv     = [ 5000 5010 5020 5030 5040 ];
    music  = [ 3000 3010 3020 3030 3040 ];
    books  = [ 7000 7010 7020 7030 ];
    all    = [ 2000 2010 2020 2030 2040 2050 5000 5010 5020 5030 5040 ];
  };

in {
  _module.args.mediaLib = { inherit mkArr mkStreamingService newznabCategories; };
}
