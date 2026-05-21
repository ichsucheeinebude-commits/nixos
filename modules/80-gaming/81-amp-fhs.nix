# ---NIXMETA
# ---
# domain: 80
# id: "NIXH-80-AMF-001"
# title: "AMP FHS Wrapper"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [amp, fhs]
# description: "AMP FHS Wrapper module."
# path: "modules/80-gaming/81-amp-fhs.nix"
# provides: [my.gaming.amp_fhs]
# requires: [80-gaming/80-amp]
# links:
#   adr: docs/adr/ADR-80-amp-fhs.md
#   guide: docs/guides/80-amp-fhs.md
#   module: modules/80-gaming/81-amp-fhs.nix
# ---
# ---ENDNIXMETA
{ pkgs, ... }:

pkgs.buildFHSEnv {
  name = "amp-fhs";
  targetPkgs = pkgs: with pkgs; [
    dotnet-sdk_8
    glibc
    glibc.dev
    stdenv.cc.cc.lib # libstdc++
    openssl
    curl
    libicu
    sqlite
    screen
    bash
    coreutils
    procps
    findutils
    steamcmd
    icu
    zlib
    krb5
  ];
  multiPkgs = pkgs: with pkgs; [
    pkgsi686Linux.glibc
  ];
  runScript = "bash";
}
