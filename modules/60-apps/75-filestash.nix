# ---NIXMETA
# ---
# domain: 60
# id: "NIXH-60-APP-075"
# title: "Filestash"
# type: module
# status: draft
# reviewed: 2026-05-22
# tags: [apps,filestash,file-manager,webdav,s3,sftp,transcoding,office-editing]
# description: "Universal file management platform with WebDAV, S3, SFTP, FTP backends. Audio/video transcoding and office document editing."
# path: "modules/60-apps/75-filestash.nix"
# provides: [my.services.filestash]
# requires: [10-network, 20-caddy]
# links:
#   module: modules/60-apps/75-filestash.nix
#   upstream: https://www.filestash.app/
#   source: https://github.com/mickael-kerjean/filestash
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Filestash Module
#
# Filestash is NOT in nixpkgs (RFP: NixOS/nixpkgs#169231).
# This module packages it from the official Docker Hub image
# (machines/filestash) using dockerTools.
#
# Key features:
# - Universal file manager (WebDAV, S3, SFTP, FTP, SMB, IPFS, etc.)
# - Audio/video transcoding (ffmpeg)
# - Office document editing (OnlyOffice/Collabora plugins)
# - SSO/Auth integration (LDAP, SAML, OIDC, htpasswd)
# - Plugin architecture
# - Theme.park theming support (via arr-stack themepark hook)
#
# ### State Management
#
# State lives in /data/.state/filestash/ (nixarr pattern).
# Config is set via web admin UI at first setup on :8334.
#
# ### Package Updates
#
# When upstream Docker image changes, update:
# 1. finalImageDigest (from Docker Hub API)
# 2. finalImageHash (dockerTools reports correct hash on mismatch)
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.services.filestash;
  domain = config.my.core.identity.domain or "example.com";
  subdomain = config.my.core.identity.subdomain or "nix";
  stateDir = config.my.core.paths.stateDir or "/data/state";
  filestashStateDir = "${stateDir}/.state/filestash";

  # ── Filestash from Docker Hub ──
  # Image: machines/filestash (official)
  # Docker Hub API: curl -s "https://hub.docker.com/v2/repositories/machines/filestash/tags/latest/images"

  filestashImage = pkgs.dockerTools.pullImage {
    imageName = "machines/filestash";
    finalImageDigest = "sha256:d81347187323e12844bf151da7d7c4fb1bb3903857d5d007439639d76babf1df";
    # Hash of the combined image tarball.
    # On first build, dockerTools will fail with the correct hash — update it here.
    finalImageHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    arch = "amd64";
    os = "linux";
    unpack = true;
  };

  # Extract the filestash binary from the Docker image layers.
  # The Dockerfile copies dist/ (containing the binary at /app/filestash)
  # into the image. We find and extract it from the unpacked layer tarballs.
  filestashBin = pkgs.stdenv.mkDerivation {
    pname = "filestash-bin";
    version = "latest";
    src = filestashImage;

    phases = [ "unpackPhase" "patchPhase" "installPhase" ];

    unpackPhase = ''
      mkdir -p $TMPDIR/extracted
      # The unpacked Docker image contains layer tarballs
      # Find the layer containing the filestash binary
      found=0
      for layer in "$src"/*.tar.gz "$src"/*.tar; do
        [ -f "$layer" ] || continue
        if tar tzf "$layer" 2>/dev/null | grep -q "app/filestash$"; then
          tar xzf "$layer" -C $TMPDIR/extracted --wildcards "*/app/filestash" 2>/dev/null || \
          tar xf "$layer"  -C $TMPDIR/extracted --wildcards "*/app/filestash" 2>/dev/null
          if [ -f "$TMPDIR/extracted/app/filestash" ]; then
            cp "$TMPDIR/extracted/app/filestash" ./filestash
            found=1
            break
          fi
          # Try without leading directory
          tar xzf "$layer" -C $TMPDIR/extracted --wildcards "app/filestash" 2>/dev/null || \
          tar xf "$layer"  -C $TMPDIR/extracted --wildcards "app/filestash" 2>/dev/null
          if [ -f "$TMPDIR/extracted/app/filestash" ]; then
            cp "$TMPDIR/extracted/app/filestash" ./filestash
            found=1
            break
          fi
        fi
      done
      if [ "$found" -ne 1 ]; then
        echo "ERROR: Could not find filestash binary in Docker image layers"
        echo "Contents of src:"
        ls -la "$src"/
        exit 1
      fi
    '';

    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [
      pkgs.stdenv.cc.cc.lib
      pkgs.ffmpeg
      pkgs.brotli
      pkgs.libjpeg_turbo
      pkgs.libtiff
      pkgs.libpng
      pkgs.libwebp
      pkgs.libraw
      pkgs.libheif
      pkgs.giflib
      pkgs.vips
      pkgs.curl
      pkgs.cacert
      pkgs.zlib
      pkgs.glibc
    ];

    installPhase = ''
      mkdir -p $out/bin
      cp ./filestash $out/bin/filestash
      chmod +x $out/bin/filestash
    '';
  };

  filestashPkg = filestashBin;
in
{
  options.my.services.filestash = {
    enable = lib.mkEnableOption "Filestash universal file management platform";

    port = lib.mkOption {
      type = lib.types.port;
      default = 8334;
      description = "Port for the Filestash web UI (default: 8334).";
    };

    domain = lib.mkOption {
      type = lib.types.str;
      default = "files.${subdomain}.${domain}";
      description = "Domain for the Filestash web UI.";
    };

    # ── Storage Providers ──
    providers = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ftp" "sftp" "s3" "webdav" "local" ];
      description = ''
        Storage backend plugins to advertise. Common options:
        ftp, sftp, s3, webdav, local, smb, nfs, ipfs, dropbox,
        google-drive, onedrive, sharepoint, backblaze, azure,
        dav, git, zip, tarsnap.
        Actual backend configuration is done via the web admin UI.
      '';
    };

    # ── Authentication ──
    auth = {
      method = lib.mkOption {
        type = lib.types.enum [ "none" "htpasswd" "ldap" "saml" "oidc" "sso" ];
        default = "none";
        description = ''
          Authentication method.
          "none"    — Filestash built-in admin setup (first-run wizard).
          "sso"     — Integrates with Pocket-ID via Caddy SSO auth.
          "htpasswd" — Basic auth via htpasswd file.
          "ldap" / "saml" / "oidc" — Enterprise SSO (config via web UI).
        '';
      };

      htpasswdFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        default = null;
        description = "Path to htpasswd file (required when auth.method = htpasswd).";
      };
    };

    # ── Theme.park Integration ──
    themepark = {
      enable = lib.mkEnableOption "Enable theme.park theming for Filestash";

      theme = lib.mkOption {
        type = lib.types.str;
        default = "dracula";
        description = "theme.park theme name. See https://docs.theme-park.dev/theme-options/";
      };
    };

    # ── Advanced ──
    stateDir = lib.mkOption {
      type = lib.types.str;
      default = filestashStateDir;
      description = "State directory for Filestash config, plugins, and cache.";
    };
  };

  config = lib.mkIf cfg.enable {
    # ── State Directory Structure ──
    systemd.tmpfiles.rules = [
      "d ${cfg.stateDir} 0750 filestash filestash -"
      "d ${cfg.stateDir}/state 0750 filestash filestash -"
      "d ${cfg.stateDir}/state/config 0750 filestash filestash -"
      "d ${cfg.stateDir}/state/plugin 0750 filestash filestash -"
      "d ${cfg.stateDir}/cache 0750 filestash filestash -"
    ];

    # ── System User ──
    users.groups.filestash = { };
    users.users.filestash = {
      isSystemUser = true;
      group = "filestash";
      home = cfg.stateDir;
      createHome = false;
      description = "Filestash service user";
    };

    # ── Filestash Service ──
    systemd.services.filestash = {
      description = "Filestash Universal File Manager";
      wantedBy = [ "multi-user.target" ];
      after = [ "network-online.target" ];
      wants = [ "network-online.target" ];

      environment = {
        FILESTASH_STATE_DIR = cfg.stateDir;
        FILESTASH_CACHE_DIR = "${cfg.stateDir}/cache";
        HOME = cfg.stateDir;
      };

      serviceConfig = {
        Type = "simple";
        ExecStart = "${lib.getExe filestashPkg}";
        WorkingDirectory = cfg.stateDir;
        User = "filestash";
        Group = "filestash";

        # ── Hardening ──
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        PrivateDevices = true;
        NoNewPrivileges = true;
        ProtectKernelTunables = true;
        ProtectKernelModules = true;
        ProtectControlGroups = true;
        RestrictSUIDSGID = true;
        RestrictNamespaces = true;
        LockPersonality = true;
        MemoryDenyWriteExecute = true;
        RestrictRealtime = true;
        ProtectHostname = true;
        ProtectClock = true;
        ProtectProc = "invisible";
        ProcSubset = "pid";

        ReadWritePaths = [ cfg.stateDir ];

        OOMScoreAdjust = 200;
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    # ── Caddy Reverse Proxy ──
    services.caddy.virtualHosts.${cfg.domain} = {
      extraConfig = lib.mkMerge [
        (lib.mkIf (cfg.auth.method == "sso") ''
          import sso_auth
        '')
        ''
          reverse_proxy 127.0.0.1:${toString cfg.port}
        ''
      ];
    };

    # ── Theme.park CSS Injection (optional) ──
    # When themepark is enabled alongside the arr-stack, the theme
    # is applied via the shared theme-park.dev CDN endpoint.
    # Filestash also supports custom CSS via its admin UI.
    services.caddy.virtualHosts.${cfg.domain}.extraConfig = lib.mkIf cfg.themepark.enable ''
      # Theme.park: serve CSS for Filestash
      handle /theme-park/filestash.css {
        respond 302
        header Location "https://theme-park.dev/css/base/filestash/${cfg.themepark.theme}.css"
      }
    '';

    # ── Firewall ──
    # Filestash binds to localhost; Caddy handles external access.
    # Only open the port if Caddy is disabled.
    networking.firewall.allowedTCPPorts = lib.mkIf (config.services.caddy.enable == false) [ cfg.port ];
  };
}
