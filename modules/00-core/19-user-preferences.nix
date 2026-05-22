# ---NIXMETA
# ---
# domain: 00
# id: "NIXH-00-CORE-019"
# title: "User Preferences"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-22
# tags: [core,identity,user,appearance,network,preferences]
# description: "Central user-configurable identity and preference settings: domain, user account, appearance, and network."
# path: "modules/00-core/19-user-preferences.nix"
# provides: [my.core.identity, my.core.user, my.core.appearance, my.core.network]
# requires: [my.core.principles]
# links:
#   adr: docs/adr/ADR-00-core.md
#   guide: docs/guides/00-core.md
#   module: modules/00-core/19-user-preferences.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### 🏗️ 1. USER LAYER: MODULARITÄT OHNE SCHMERZ (KISS)
#
# In herkömmlichen Nix-Systemen musst du jede neue Datei manuell in einer Liste eintragen. In unserem System ist das vorbei:
# - **Prinzip:** "Jede Datei ist ein Modul".
# - **Aktion:** Erstelle eine `.nix` Datei im Ordner `features/` – sie wird sofort vom System erkannt und geladen.
# - **Vorteil:** Du kannst dich auf das Konfigurieren konzentrieren, anstatt dich um Import-Strukturen zu kümmern.
#
# ---
# ### A. Die Engine: `flake-parts` & `den`
#
# Wir nutzen `flake-parts` als Basis und das `den` Framework zur Kontext-Steuerung.
# - **Auto-Import:** Integration von `import-tree`, um das gesamte Verzeichnis `./modules` rekursiv zu evaluieren.
# - **Deferred Modules:** Wir nutzen den Typ `deferredModule` aus Nixpkgs für Sub-Module, um Konflikte beim Mergen von Attributen (z.B. Firewall-Regeln) zu minimieren.
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.core;

  # ── Proxy environment helper ──
  proxyEnvVars =
    let
      http  = cfg.network.proxy.http;
      https = cfg.network.proxy.https;
      no    = lib.concatStringsSep "," cfg.network.proxy.noProxy;
    in
    {
      HTTP_PROXY       = lib.mkIf (http  != "") http;
      http_proxy       = lib.mkIf (http  != "") http;
      HTTPS_PROXY      = lib.mkIf (https != "") https;
      https_proxy      = lib.mkIf (https != "") https;
      NO_PROXY         = lib.mkIf (no   != "") no;
      no_proxy         = lib.mkIf (no   != "") no;
    };
in
{

  # ═══════════════════════════════════════════
  #  IDENTITY
  # ═══════════════════════════════════════════
  options.my.core.identity = {
    domain = lib.mkOption {
      type = lib.types.str;
      default = "local";
      description = "Network domain name (e.g. local, lan, home.arpa).";
    };

    hostname = lib.mkOption {
      type = lib.types.str;
      default = "nixos";
      description = "System hostname.";
    };

    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "System timezone (e.g. Europe/Berlin, America/New_York).";
    };

    locale = lib.mkOption {
      type = lib.types.str;
      default = "en_US.UTF-8";
      description = "Default system locale.";
    };

    keyboardLayout = lib.mkOption {
      type = lib.types.str;
      default = "de";
      description = "Keyboard layout for console and X11 (e.g. de, us).";
    };
  };

  # ═══════════════════════════════════════════
  #  USER
  # ═══════════════════════════════════════════
  options.my.core.user = {
    username = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary username (empty = skip user creation).";
    };

    fullName = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Full display name (e.g. Geändert Name).";
    };

    email = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Primary email address.";
    };

    shell = lib.mkOption {
      type = lib.types.package;
      default = pkgs.fish;
      description = "Default login shell package.";
    };
  };

  # ═══════════════════════════════════════════
  #  APPEARANCE
  # ═══════════════════════════════════════════
  options.my.core.appearance = {
    cursorTheme = lib.mkOption {
      type = lib.types.str;
      default = "Bibata-Modern-Classic";
      description = "Cursor theme name (must be installed via packages or NixOS options).";
    };

    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "Papirus";
      description = "Icon theme name.";
    };

    fontFamily = lib.mkOption {
      type = lib.types.str;
      default = "Inter";
      description = "Primary font family name.";
    };

    fontSize = lib.mkOption {
      type = lib.types.int;
      default = 11;
      description = "Default font size in points.";
    };
  };

  # ═══════════════════════════════════════════
  #  NETWORK
  # ═══════════════════════════════════════════
  options.my.core.network = {
    dns = {
      servers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "1.1.1.1" "1.0.0.1" ];
        description = "DNS server addresses.";
      };
      fallbackServers = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "8.8.8.8" "8.8.4.4" ];
        description = "Fallback DNS server addresses.";
      };
    };

    proxy = {
      enable = lib.mkEnableOption "system-wide HTTP/HTTPS proxy";

      http = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "HTTP proxy URL (e.g. http://proxy.example.com:8080).";
      };

      https = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "HTTPS proxy URL (e.g. http://proxy.example.com:8080).";
      };

      noProxy = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ "localhost" "127.0.0.1" "::1" ];
        description = "Host/domains to exclude from proxying.";
      };
    };
  };

  # ═══════════════════════════════════════════
  #  CONFIG
  # ═══════════════════════════════════════════
  config = lib.mkIf config.my.core.principles.enable {

    # ── Identity: hostname, timezone, locale, keymap ──
    networking.hostName = lib.mkIf (cfg.identity.hostname != "nixos")
      cfg.identity.hostname;

    networking.domain = lib.mkIf (cfg.identity.domain != "local")
      cfg.identity.domain;

    time.timeZone = lib.mkIf (cfg.identity.timezone != "Europe/Berlin")
      cfg.identity.timezone;

    i18n.defaultLocale = lib.mkIf (cfg.identity.locale != "")
      cfg.identity.locale;

    console.keyMap = lib.mkIf (cfg.identity.keyboardLayout != "us")
      cfg.identity.keyboardLayout;

    services.xserver.xkb.layout = lib.mkIf (cfg.identity.keyboardLayout != "us")
      cfg.identity.keyboardLayout;

    i18n.supportedLocales = lib.mkIf (cfg.identity.locale != "")
      [ "${cfg.identity.locale}/UTF-8" "en_US.UTF-8/UTF-8" ];

    # ── User: create primary user ──
    users.users = lib.mkIf (cfg.user.username != "") {
      ${cfg.user.username} = {
        isNormalUser = true;
        description = lib.mkIf (cfg.user.fullName != "") cfg.user.fullName;
        shell = cfg.user.shell;
        extraGroups = [ "networkmanager" "wheel" ];
      };
    };

    # ── User: environment variables ──
    environment.variables = lib.mkMerge [
      {
        EDITOR  = lib.mkIf (cfg.user.username != "") "${pkgs.micro}/bin/micro";
        LANG    = lib.mkIf (cfg.identity.locale != "") cfg.identity.locale;
      }
      (lib.mkIf (cfg.network.proxy.enable) proxyEnvVars)
    ];

    # ── User: shell profile with identity info ──
    environment.etc."profile.d/identity.sh".text = lib.mkIf (cfg.user.username != "") ''
      export USER_NAME="${cfg.user.username}"
      ${lib.optionalString (cfg.user.fullName != "") ''export USER_FULLNAME="${cfg.user.fullName}"''}
      ${lib.optionalString (cfg.user.email != "")    ''export USER_EMAIL="${cfg.user.email}"''}
      export USER_HOST="${cfg.identity.hostname}"
      export USER_DOMAIN="${cfg.identity.domain}"
    '';

    # ── Appearance: cursor, icons, fonts ──
    environment.systemPackages = with pkgs; [
      papirus-icon-theme
    ];

    fonts = {
      packages = with pkgs; [
        # Default font family packages – extend as needed
        inter
        noto-fonts
        noto-fonts-emoji
        nerd-fonts.fira-code
      ];

      fontconfig.defaultFonts = {
        monospace = [ "FiraCode Nerd Font" cfg.appearance.fontFamily ];
        serif     = [ cfg.appearance.fontFamily "Noto Serif" ];
        sansSerif = [ cfg.appearance.fontFamily "Noto Sans" ];
        emoji     = [ "Noto Color Emoji" ];
      };
    };

    # ── Network: DNS ──
    networking.nameservers = lib.mkIf (cfg.network.dns.servers != [])
      cfg.network.dns.servers;

    # ── Network: proxy — profile.d script for all login sessions ──
    environment.etc."profile.d/proxy.sh".text = lib.mkIf cfg.network.proxy.enable ''
      ${lib.optionalString (cfg.network.proxy.http  != "") ''export HTTP_PROXY="${cfg.network.proxy.http}"''}
      ${lib.optionalString (cfg.network.proxy.http  != "") ''export http_proxy="${cfg.network.proxy.http}"''}
      ${lib.optionalString (cfg.network.proxy.https != "") ''export HTTPS_PROXY="${cfg.network.proxy.https}"''}
      ${lib.optionalString (cfg.network.proxy.https != "") ''export https_proxy="${cfg.network.proxy.https}"''}
      ${lib.optionalString ((lib.concatStringsSep "," cfg.network.proxy.noProxy) != "") ''export NO_PROXY="${lib.concatStringsSep "," cfg.network.proxy.noProxy}"''}
      ${lib.optionalString ((lib.concatStringsSep "," cfg.network.proxy.noProxy) != "") ''export no_proxy="${lib.concatStringsSep "," cfg.network.proxy.noProxy}"''}
    '';
  };
}
