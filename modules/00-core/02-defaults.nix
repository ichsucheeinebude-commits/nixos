# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-COR-009"
# title: "Global Defaults"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [defaults,paths,locale,security,abc-tiering]
# description: "Shared global defaults: ABC tiering paths, locale, security conventions, network namespaces."
# path: "modules/00-core/02-defaults.nix"
# provides: [my.defaults]
# requires: []
# links:
#   module: modules/00-core/02-defaults.nix
# source: _meta/00-core/defaults.nix (NIXH-00-COR-009)
# ---
# ---ENDNIXMETA
{ lib, ... }:
{
  options.my.defaults = {
    # ── Network ──
    netns = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Default network namespace for all services.";
    };
    bindAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      description = "Default bind address for all services.";
    };

    # ── Locale ──
    locale = {
      timezone = lib.mkOption { type = lib.types.str; default = "Europe/Berlin"; };
      language = lib.mkOption { type = lib.types.str; default = "de_DE.UTF-8"; };
      dateOrder = lib.mkOption { type = lib.types.enum [ "DMY" "MDY" "YMD" ]; default = "DMY"; };
    };

    # ── OCR ──
    ocr = {
      languages = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "deu" "eng" ]; };
      outputType = lib.mkOption { type = lib.types.enum [ "pdfa" "pdfa-1" "pdfa-2" "pdfa-3" "pdf" "none" ]; default = "pdfa"; };
    };

    # ── Filesystem Prefixes (ABC Tiering) ──
    paths = {
      statePrefix = lib.mkOption { type = lib.types.str; default = "/data/state"; description = "State directory prefix."; };
      mediaRoot = lib.mkOption { type = lib.types.str; default = "/mnt/media"; description = "Media root directory."; };
      downloadsDir = lib.mkOption { type = lib.types.str; default = "/mnt/media/downloads"; };
      fastPoolRoot = lib.mkOption { type = lib.types.str; default = "/mnt/fast-pool"; description = "Fast pool (NVMe/SSD) root."; };
      documentRoot = lib.mkOption { type = lib.types.str; default = "/mnt/documents"; };
      backupRoot = lib.mkOption { type = lib.types.str; default = "/mnt/backup"; };
    };

    # ── Security ──
    security = {
      defaultGroup = lib.mkOption { type = lib.types.str; default = "media"; };
      ssoEnable = lib.mkOption { type = lib.types.bool; default = true; };
    };

    # ── Observability ──
    observability = {
      logLevel = lib.mkOption { type = lib.types.enum [ "DEBUG" "INFO" "WARNING" "ERROR" ]; default = "WARNING"; };
      metricsPortOffset = lib.mkOption { type = lib.types.int; default = 9000; };
    };
  };
}
