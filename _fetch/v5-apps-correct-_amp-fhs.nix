# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-060-GAM-AMP-FHS",
#   "title": "AMP FHS Sandbox",
#   "layer": 60,
#   "category": "apps/gaming",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 2,
#   "tags": ["gaming", "amp", "fhs", "sandbox"],
#   "description": "FHS Sandbox for AMP Game Server Panel (Native / Docker-free)."
# }
# ---ENDNIXMETA

{ pkgs, ... }:

# 📦 AMP FHS ENVIRONMENT (anchor: amp-fhs)
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
