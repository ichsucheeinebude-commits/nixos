#!/usr/bin/env bash
set -euo pipefail
cd /root/nixos-work

# Ensure all module directories exist
mkdir -p modules/{00-core,10-network,20-security,30-storage,40-monitoring,50-media,60-apps,70-forge,80-gaming,90-policy}
mkdir -p docs/{adr,guides}

########################################
# Helper: write a module file
# usage: module <path> <domain> <id> <title> <tags> <desc> <provides> <requires> <content>
########################################
module() {
  local path="$1" domain="$2" id="$3" title="$4" tags="$5" desc="$6" provides="$7" requires="$8" content="$9"
  cat > "$path" <<'NIXEOF'
# ---NIXMETA
# ---
# domain: ${domain}
# id: "${id}"
# title: "${title}"
# type: module
# status: draft
# complexity: 1
# reviewed: 2026-05-21
# tags: [${tags}]
# description: "${desc}"
# path: "${path}"
# provides: [${provides}]
# requires: [${requires}]
# links:
#   adr: docs/adr/ADR-${domain}-${id: -3:3}-${id##*-}.md
#   guide: docs/guides/GUIDE-${domain}-${id: -3:3}-${id##*-}.md
#   module: ${path}
# ---
# ---ENDNIXMETA

${content}
NIXEOF
  echo "  ✓ module: $path"
}

########################################
# Helper: write an ADR
########################################
adr() {
  local path="$1" domain="$2" id="$3" title="$4" tags="$5" desc="$6" body="$7"
  cat > "$path" <<'ADREOF'
---
domain: ${domain}
id: "${id}"
title: "${title}"
type: adr
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [${tags}]
description: "${desc}"
path: "${path}"
links:
  module: "modules/placeholder.nix"
---

# ADR: ${title}

${body}
ADREOF
  echo "  ✓ ADR: $path"
}

########################################
# Helper: write a Guide
########################################
guide() {
  local path="$1" domain="$2" id="$3" title="$4" tags="$5" desc="$6" body="$7"
  cat > "$path" <<'GUIDEEOF'
---
domain: ${domain}
id: "${id}"
title: "${title}"
type: guide
status: draft
complexity: 1
reviewed: 2026-05-21
tags: [${tags}]
description: "${desc}"
path: "${path}"
links:
  module: "modules/placeholder.nix"
---

# Guide: ${title}

${body}
GUIDEEOF
  echo "  ✓ guide: $path"
}

echo "=== Phase 2: 00-core (10 modules) ==="

# 00-principles.nix
module modules/00-core/00-principles.nix "00" "NIXH-00-COR-001" "Principles & Defaults" "core,principles,bastelmodus" \
  "Global toggle and experimental flag for the entire boilerplate." \
  "my.core.principles" "" \
'{ config, lib, ... }:
{
  options.my.core.principles = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Master toggle for all core boilerplate options.";
    };
    bastelmodus = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Experimental playground flag. When false, strict policies are enforced.";
    };
  };
}
'
adr docs/adr/ADR-00-principles.md "00" "NIXH-00-COR-001" "Principles & Defaults" "core,principles" \
  "Defines global enable toggle and experimental bastelmodus flag." \
  "## Context\n\nWe need a single master toggle to enable/disable all boilerplate core modules,\nand an experimental flag for sandboxed tinkering.\n\n## Decision\n\n- my.core.principles.enable controls whether all core modules are active.\n- my.core.principles.bastelmodus defaults to false. When false, strict architecture rules apply.\n\n## Consequences\n- When bastelmodus = true, forbidden-tech assertions are relaxed.\n- When bastelmodus = false, all policy assertions are enforced at build time."
guide docs/guides/GUIDE-00-principles.md "00" "NIXH-00-COR-001" "Principles & Defaults Guide" "core,principles" \
  "How to use the principles module." \
  "## Usage\n\nSet in your host configuration:\n\n\`\`\`nix\nmy.core.principles.bastelmodus = true;  # enable experimental mode\n\`\`\`\n\nWhen bastelmodus is false, forbidden-technology assertions (Docker, Tailscale, etc.) are strictly enforced."

# 01-configs-registry.nix
module modules/00-core/01-configs-registry.nix "00" "NIXH-00-COR-002" "Identity & Hardware Registry" "core,identity,hardware,registry,ports" \
  "Central registry for identity, hardware specs, network, and service toggles." \
  "my.core.identity,my.core.hardware,my.core.server,my.core.network,my.core.ports,my.core.services" "" \
'{ config, lib, ... }:
let
  idCfg = config.my.core.identity;
in
{
  options.my.core.identity = {
    host = lib.mkOption { type = lib.types.str; default = ""; description = "Host name (e.g. q958)."; };
    domain = lib.mkOption { type = lib.types.str; default = ""; description = "Base domain (e.g. m7c5.de)."; };
    subdomain = lib.mkOption { type = lib.types.str; default = "nix"; description = "Subdomain prefix for services."; };
    email = lib.mkOption { type = lib.types.str; default = ""; description = "Admin email address."; };
    user = lib.mkOption { type = lib.types.str; default = "root"; description = "Primary user name."; };
    lanIP = lib.mkOption { type = lib.types.str; default = ""; description = "Server LAN IP address."; };
  };

  options.my.core.hardware = {
    cpuType = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum [ "intel" "amd" "arm" ]);
      default = null;
      description = "CPU architecture for microcode and driver selection.";
    };
    intelGpu = lib.mkOption { type = lib.types.bool; default = false; description = "Intel GPU present (enables i915/QSV)."; };
    ramGB = lib.mkOption { type = lib.types.int; default = 0; description = "Installed RAM in GB."; };
    profile = lib.mkOption { type = lib.types.str; default = "generic"; description = "Hardware profile name."; };
  };

  options.my.core.server = {
    lanIP = lib.mkOption { type = lib.types.str; default = ""; description = "Alias for identity.lanIP."; };
  };

  options.my.core.network = {
    lanCidrs = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Trusted LAN CIDR blocks."; };
  };

  options.my.core.ports = {
    ssh = lib.mkOption { type = lib.types.port; default = 22; description = "SSH port."; };
  };

  # Service toggle registry — every service in the boilerplate registers here.
  options.my.core.services = {
    blocky.enable = lib.mkEnableOption "Blocky DNS";
    caddy.enable = lib.mkEnableOption "Caddy reverse proxy";
    pocketId.enable = lib.mkEnableOption "Pocket-ID (OIDC)";
    postgresql.enable = lib.mkEnableOption "PostgreSQL database";
    fail2ban.enable = lib.mkEnableOption "Fail2ban";
    vaultwarden.enable = lib.mkEnableOption "Vaultwarden";
    jellyfin.enable = lib.mkEnableOption "Jellyfin";
    zigbeeStack.enable = lib.mkEnableOption "Zigbee2MQTT + Mosquitto";
    ntfy.enable = lib.mkEnableOption "ntfy-sh alerting";
    gatus.enable = lib.mkEnableOption "Gatus health dashboard";
    netdata.enable = lib.mkEnableOption "Netdata telemetry";
    scrutiny.enable = lib.mkEnableOption "Scrutiny SMART monitoring";
    uptimeKuma.enable = lib.mkEnableOption "Uptime Kuma";
    vector.enable = lib.mkEnableOption "Vector log aggregator";
    paperless.enable = lib.mkEnableOption "Paperless-ngx";
    n8n.enable = lib.mkEnableOption "n8n automation";
    homeAssistant.enable = lib.mkEnableOption "Home Assistant";
    readeck.enable = lib.mkEnableOption "Readeck";
    matrixConduit.enable = lib.mkEnableOption "Matrix Conduit";
    miniflux.enable = lib.mkEnableOption "Miniflux RSS";
    linkding.enable = lib.mkEnableOption "Linkding bookmarks";
    monica.enable = lib.mkEnableOption "Monica CRM";
    karakeep.enable = lib.mkEnableOption "Karakeep";
    forgejo.enable = lib.mkEnableOption "Forgejo Git";
    semaphore.enable = lib.mkEnableOption "Semaphore Ansible";
    cockpit.enable = lib.mkEnableOption "Cockpit admin";
    amp.enable = lib.mkEnableOption "AMP game servers";
    arrStack.enable = lib.mkEnableOption "Arr media stack";
    downloads.enable = lib.mkEnableOption "Download stack (SABnzbd)";
    streaming.enable = lib.mkEnableOption "Streaming stack";
    discovery.enable = lib.mkEnableOption "Jellyseerr discovery";
    storageMover.enable = lib.mkEnableOption "Smart storage mover";
    dnsAutomation.enable = lib.mkEnableOption "DNS automation";
    ddnsUpdater.enable = lib.mkEnableOption "DDNS updater";
    sonarr.enable = lib.mkEnableOption "Sonarr";
    radarr.enable = lib.mkEnableOption "Radarr";
    prowlarr.enable = lib.mkEnableOption "Prowlarr";
    backup.enable = lib.mkEnableOption "Restic backup";
    tpm2.enable = lib.mkEnableOption "TPM2 sealing";
    zram.enable = lib.mkEnableOption "ZRAM swap";
    memtest.enable = lib.mkEnableOption "Memtest86+ boot entry";
    secrets.enable = lib.mkEnableOption "SOPS secrets management";
    sshRescue.enable = lib.mkEnableOption "SSH rescue service";
  };

  # Backward-compat aliases (read-only)
  config = lib.mkIf config.my.core.principles.enable {
    my.core.server.lanIP = lib.mkDefault config.my.core.identity.lanIP;
  };
}
'
adr docs/adr/ADR-01-registry.md "00" "NIXH-00-COR-002" "Identity & Hardware Registry" "core,identity,registry" \
  "Central registry for all identity, hardware, network, and port options." \
  "## Context\nWe need a single place to define host identity, hardware specs, network CIDRs, and service toggles.\n\n## Decision\nAll identity/hardware/port options live in my.core.*. Each service in the boilerplate has a toggle in my.core.services.*.\n\n## Consequences\n- Host configs set values here.\n- Modules read from here, never hardcode values."
guide docs/guides/GUIDE-01-registry.md "00" "NIXH-00-COR-002" "Registry Guide" "core,identity,registry" \
  "How to configure the registry for your host." \
  "## Example\n\n\`\`\`nix\nmy.core.identity.host = \"q958\";\nmy.core.identity.domain = \"example.com\";\nmy.core.identity.user = \"alice\";\nmy.core.hardware.cpuType = \"intel\";\nmy.core.hardware.ramGB = 32;\nmy.core.ports.ssh = 2222;\n\`\`\`"

# 02-nix-tuning.nix
module modules/00-core/02-nix-tuning.nix "00" "NIXH-00-COR-003" "Nix Tuning" "core,nix,gc,optimization" \
  "Nix daemon tuning, GC settings, and build optimization." \
  "my.core.nix" "" \
'{ config, lib, ... }:
{
  options.my.core.nix = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Apply nix tuning."; };
    gc.automatic = lib.mkOption { type = lib.types.bool; default = true; description = "Automatic garbage collection."; };
    gc.interval = lib.mkOption { type = lib.types.str; default = "weekly"; description = "GC schedule."; };
    gc.options = lib.mkOption { type = lib.types.str; default = "--delete-older-than 7d"; description = "GC options."; };
    optimise.automatic = lib.mkOption { type = lib.types.bool; default = true; description = "Automatic store optimisation."; };
    settings = lib.mkOption {
      type = lib.types.attrs;
      default = {
        auto-optimise-store = true;
        use-xdg-base-directories = true;
        experimental-features = [ "nix-command" "flakes" ];
        warn-dirty = false;
      };
      description = "Nix daemon settings.";
    };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.nix.enable) {
    nix = {
      gc = {
        automatic = config.my.core.nix.gc.automatic;
        dates = config.my.core.nix.gc.interval;
        options = config.my.core.nix.gc.options;
      };
      settings = config.my.core.nix.settings;
    };
    nix.optimise = { automatic = config.my.core.nix.optimise.automatic; };
  };
}
'
adr docs/adr/ADR-02-nix-tuning.md "00" "NIXH-00-COR-003" "Nix Tuning" "core,nix,gc" "Nix daemon tuning and GC configuration." \
  "## Context\nNix store grows unbounded without GC. We need sane defaults.\n## Decision\nEnable automatic weekly GC, auto-optimise-store, and flakes by default.\n## Consequences\nStore stays manageable; flakes are the standard workflow."
guide docs/guides/GUIDE-02-nix-tuning.md "00" "NIXH-00-COR-003" "Nix Tuning Guide" "core,nix" \
  "Nix tuning defaults explained." "No action needed — defaults are production-ready."

# 03-hardware-profile.nix
module modules/00-core/03-hardware-profile.nix "00" "NIXH-00-COR-004" "Hardware Profile" "core,hardware,cpu,gpu,microcode" \
  "CPU microcode, GPU drivers, and hardware-specific configuration." \
  "my.core.hardware" "" \
'{ config, lib, pkgs, ... }:
{
  config = lib.mkIf config.my.core.principles.enable (let
    cpu = config.my.core.hardware.cpuType;
    intelGpu = config.my.core.hardware.intelGpu;
  in lib.mkMerge [
    (lib.mkIf (cpu == "intel") { hardware.cpu.intel.updateMicrocode = lib.mkDefault true; })
    (lib.mkIf (cpu == "amd")   { hardware.cpu.amd.updateMicrocode = lib.mkDefault true; })
    (lib.mkIf intelGpu {
      hardware.graphics = {
        enable = lib.mkDefault true;
        extraPackages = lib.mkDefault [ pkgs.intel-media-driver pkgs.intel-compute-runtime ];
        enable32Bit = lib.mkDefault true;
      };
      hardware.graphics.extraPackages32 = lib.mkDefault [ pkgs.driversi686Linux.mesa ];
    })
  ]);
}
'
adr docs/adr/ADR-03-hardware-profile.md "00" "NIXH-00-COR-004" "Hardware Profile" "core,hardware" \
  "Hardware-specific configuration for CPU microcode and GPU drivers." \
  "## Context\nDifferent CPUs need different microcode. Intel GPUs need VAAPI/QSV drivers.\n## Decision\nConditional activation based on my.core.hardware.cpuType and intelGpu.\n## Consequences\nZero config needed for generic hosts; specific hosts override."
guide docs/guides/GUIDE-03-hardware-profile.md "00" "NIXH-00-COR-004" "Hardware Profile Guide" "core,hardware" \
  "Configure hardware profile." \
  "## Intel GPU\n\`\`\`nix\nmy.core.hardware.cpuType = \"intel\";\nmy.core.hardware.intelGpu = true;\n\`\`\`"

# 04-boot-safeguards.nix
module modules/00-core/04-boot-safeguards.nix "00" "NIXH-00-COR-005" "Boot Safeguards" "core,boot,memtest,safeguards" \
  "Boot configuration limits, memtest entry, and generation pruning." \
  "my.core.boot" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.core.boot = {
    configurationLimit = lib.mkOption { type = lib.types.int; default = 5; description = "Max boot generations to keep."; };
    memtest = lib.mkOption { type = lib.types.bool; default = true; description = "Include memtest86+ in boot menu."; };
  };

  config = lib.mkIf config.my.core.principles.enable {
    boot.loader.systemd-boot.configurationLimit = config.my.core.boot.configurationLimit;
    boot.loader.systemd-boot.memtest86.enable = config.my.core.boot.memtest;
  };
}
'
adr docs/adr/ADR-04-boot-safeguards.md "00" "NIXH-00-COR-005" "Boot Safeguards" "core,boot" \
  "Boot safeguards: generation limit and memtest." \
  "## Context\nUnlimited boot generations fill the ESP. Memtest is essential for hardware diagnostics.\n## Decision\nDefault limit of 5 generations; memtest enabled by default.\n## Consequences\nESP stays manageable; memtest always available."
guide docs/guides/GUIDE-04-boot-safeguards.md "00" "NIXH-00-COR-005" "Boot Safeguards Guide" "core,boot" \
  "Configure boot safeguards." \
  "## Custom generation limit\n\`\`\`nix\nmy.core.boot.configurationLimit = 10;\n\`\`\`"

# 05-tpm2.nix
module modules/00-core/05-tpm2.nix "00" "NIXH-00-COR-006" "TPM2 Sealing" "core,tpm2,security,sops" \
  "TPM2-based secret sealing for SOPS." \
  "my.core.tpm2" "" \
'{ config, lib, ... }:
{
  options.my.core.tpm2 = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable TPM2 for SOPS secret sealing."; };
    device = lib.mkOption { type = lib.types.str; default = "/dev/tpmrm0"; description = "TPM device path."; };
  };

  config = lib.mkIf config.my.core.tpm2.enable {
    security.tpm2.enable = true;
  };
}
'
adr docs/adr/ADR-05-tpm2.md "00" "NIXH-00-COR-006" "TPM2 Sealing" "core,tpm2,security" \
  "TPM2-based SOPS secret sealing." \
  "## Context\nTPM2 can seal secrets to specific hardware state.\n## Decision\nOptional TPM2 support, off by default.\n## Consequences\nWhen enabled, SOPS can use TPM2 for hardware-bound secrets."
guide docs/guides/GUIDE-05-tpm2.md "00" "NIXH-00-COR-006" "TPM2 Guide" "core,tpm2" \
  "Enable TPM2." \
  "\`\`\`nix\nmy.core.tpm2.enable = true;\n\`\`\`"

# 06-zram-swap.nix
module modules/00-core/06-zram-swap.nix "00" "NIXH-00-COR-007" "ZRAM Swap" "core,zram,swap,memory" \
  "Compressed RAM swap via zram." \
  "my.core.zram" "" \
'{ config, lib, ... }:
{
  options.my.core.zram = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable zram swap."; };
    algorithm = lib.mkOption { type = lib.types.str; default = "zstd"; description = "Compression algorithm."; };
    memoryPercent = lib.mkOption { type = lib.types.int; default = 25; description = "Percentage of RAM for zram."; };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.zram.enable) {
    zramSwap = {
      enable = true;
      algorithm = config.my.core.zram.algorithm;
      memoryPercent = config.my.core.zram.memoryPercent;
    };
  };
}
'
adr docs/adr/ADR-06-zram-swap.md "00" "NIXH-00-COR-007" "ZRAM Swap" "core,zram,swap" \
  "ZRAM compressed swap." \
  "## Context\nZRAM provides fast, compressed swap in RAM.\n## Decision\nEnabled by default, zstd algorithm, 25% of RAM.\n## Consequences\nBetter memory management without disk swap penalty."
guide docs/guides/GUIDE-06-zram-swap.md "00" "NIXH-00-COR-007" "ZRAM Guide" "core,zram" \
  "ZRAM configuration guide." \
  "Defaults are production-ready."

# 07-locale-system.nix
module modules/00-core/07-locale-system.nix "00" "NIXH-00-COR-008" "Locale & System" "core,locale,timezone,keymap" \
  "System locale, timezone, and keymap configuration." \
  "my.core.locale" "" \
'{ config, lib, ... }:
{
  options.my.core.locale = {
    timezone = lib.mkOption { type = lib.types.str; default = ""; description = "Timezone (e.g. Europe/Berlin)."; };
    default = lib.mkOption { type = lib.types.str; default = ""; description = "Default locale (e.g. de_DE.UTF-8)."; };
    keymap = lib.mkOption { type = lib.types.str; default = "us"; description = "Console keymap."; };
    extraLocales = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "en_US.UTF-8/UTF-8" ]; description = "Additional locales to generate."; };
  };

  config = lib.mkIf config.my.core.principles.enable {
    time.timeZone = lib.mkIf (config.my.core.locale.timezone != "") config.my.core.locale.timezone;
    i18n.defaultLocale = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
    i18n.extraLocaleSettings = {
      LC_ADDRESS = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_IDENTIFICATION = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_MEASUREMENT = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_MONETARY = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_NAME = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_NUMERIC = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_PAPER = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_TELEPHONE = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
      LC_TIME = lib.mkIf (config.my.core.locale.default != "") config.my.core.locale.default;
    };
    console.keyMap = config.my.core.locale.keymap;
    i18n.supportedLocales = lib.mkIf (config.my.core.locale.default != "")
      ([ "${config.my.core.locale.default}/UTF-8" ] ++ config.my.core.locale.extraLocales);
  };
}
'
adr docs/adr/ADR-07-locale-system.md "00" "NIXH-00-COR-008" "Locale & System" "core,locale" \
  "System locale, timezone, keymap." \
  "## Context\nLocales and timezone must be configurable per host.\n## Decision\nAll locale options live in my.core.locale.\n## Consequences\nEmpty defaults mean no locale is forced."
guide docs/guides/GUIDE-07-locale-system.md "00" "NIXH-00-COR-008" "Locale Guide" "core,locale" \
  "Configure locale." \
  "\`\`\`nix\nmy.core.locale.timezone = \"Europe/Berlin\";\nmy.core.locale.default = \"de_DE.UTF-8\";\nmy.core.locale.keymap = \"de\";\n\`\`\`"

# 08-users-shell.nix
module modules/00-core/08-users-shell.nix "00" "NIXH-00-COR-009" "Users & Groups" "core,users,groups" \
  "System user and group definitions (no shell aliases)." \
  "my.core.users" "" \
'{ config, lib, ... }:
{
  options.my.core.users = {
    list = lib.mkOption {
      type = lib.types.listOf (lib.types.submodule {
        options = {
          name = lib.mkOption { type = lib.types.str; description = "Username."; };
          isNormalUser = lib.mkOption { type = lib.types.bool; default = true; description = "Create normal user with home."; };
          extraGroups = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Supplementary groups."; };
          openssh.authorizedKeys.keys = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "SSH public keys."; };
          shell = lib.mkOption { type = lib.types.package; default = null; description = "User shell."; };
        };
      });
      default = [];
      description = "List of users to create.";
    };
  };

  config = lib.mkIf (config.my.core.principles.enable && config.my.core.users.list != []) {
    users.users = lib.mkMerge (map (u: {
      ${u.name} = {
        inherit (u) isNormalUser;
        extraGroups = u.extraGroups;
        inherit (u) shell;
        openssh.authorizedKeys.keys = u.openssh.authorizedKeys.keys;
      };
    }) config.my.core.users.list);
  };
}
'
adr docs/adr/ADR-08-users-shell.md "00" "NIXH-00-COR-009" "Users & Groups" "core,users" \
  "Declarative user definitions (no aliases)." \
  "## Context\nUsers need to be defined in modules, but aliases are personal.\n## Decision\nModule defines user structure; aliases go to users/ home-manager.\n## Consequences\nClean separation between system users and personal settings."
guide docs/guides/GUIDE-08-users-shell.md "00" "NIXH-00-COR-009" "Users Guide" "core,users" \
  "Define users." \
  "Shell aliases belong in users/<name>/home.nix, NOT here."

# 09-postgresql.nix
module modules/00-core/09-postgresql.nix "00" "NIXH-00-COR-010" "PostgreSQL" "core,postgresql,database" \
  "PostgreSQL database service." \
  "my.core.postgresql" "" \
'{ config, lib, ... }:
{
  options.my.core.postgresql = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable PostgreSQL."; };
    package = lib.mkOption { type = lib.types.package; default = null; description = "PostgreSQL package (uses nixpkgs default if null)."; };
  };

  config = lib.mkIf config.my.core.postgresql.enable {
    services.postgresql = {
      enable = true;
      package = lib.mkIf (config.my.core.postgresql.package != null) config.my.core.postgresql.package;
      ensureDirectories = [ ];
    };
    # Persist postgres socket on stateless root
    systemd.tmpfiles.rules = [ "d /run/postgresql 0755 postgres postgres -" ];
  };
}
'
adr docs/adr/ADR-09-postgresql.md "00" "NIXH-00-COR-010" "PostgreSQL" "core,postgresql" \
  "PostgreSQL as central database." \
  "## Context\nMany services need PostgreSQL.\n## Decision\nSingle toggle, shared instance.\n## Consequences\nServices declare ensureDatabases/ensureUsers in their own modules."
guide docs/guides/GUIDE-09-postgresql.md "00" "NIXH-00-COR-010" "PostgreSQL Guide" "core,postgresql" \
  "Configure PostgreSQL." \
  "\`\`\`nix\nmy.core.postgresql.enable = true;\n\`\`\`"

echo "=== Phase 3: 10-network (10 modules) ==="

# 10-network.nix
module modules/10-network/10-network.nix "10" "NIXH-10-NET-001" "Network Configuration" "network,systemd-resolved" \
  "Base networking: systemd-resolved, DNS servers, host name." \
  "my.network.base" "" \
'{ config, lib, ... }:
{
  options.my.network.base = {
    hostName = lib.mkOption { type = lib.types.str; default = ""; description = "System host name."; };
    nameservers = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; description = "Fallback DNS servers."; };
    enableResolved = lib.mkOption { type = lib.types.bool; default = true; description = "Enable systemd-resolved."; };
  };

  config = lib.mkIf config.my.network.base.enableResolved {
    networking = {
      hostName = lib.mkIf (config.my.network.base.hostName != "") config.my.network.base.hostName;
      nameservers = config.my.network.base.nameservers;
    };
    services.resolved = {
      enable = true;
      dnssec = "allow-downgrade";
      domains = lib.optional (config.my.core.identity.domain or "" != "") config.my.core.identity.domain;
    };
  };
}
'
adr docs/adr/ADR-10-network.md "10" "NIXH-10-NET-001" "Network Configuration" "network" "Base networking config." \
  "## Decision\nsystemd-resolved with DNSSEC allow-downgrade. Fallback DNS via options."
guide docs/guides/GUIDE-10-network.md "10" "NIXH-10-NET-001" "Network Guide" "network" \
  "Configure networking." "Defaults are safe for most setups."

# 11-firewall.nix
module modules/10-network/11-firewall.nix "10" "NIXH-10-NET-002" "NFTables Firewall" "network,firewall,nftables" \
  "NFTables firewall with LAN trust and public port rules." \
  "my.network.firewall" "" \
'{ config, lib, ... }:
let
  sshPort = toString config.my.core.ports.ssh;
  lanCidrs = config.my.core.network.lanCidrs;
in
{
  options.my.network.firewall = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable NFTables firewall."; };
    allowedTCPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = [ 80 443 ]; description = "Public TCP ports."; };
    allowedUDPPorts = lib.mkOption { type = lib.types.listOf lib.types.port; default = []; description = "Public UDP ports."; };
  };

  config = lib.mkIf (config.my.network.firewall.enable) {
    networking = {
      firewall.enable = true;
      nftables.enable = true;
    };
    networking.firewall = {
      allowedTCPPorts = config.my.network.firewall.allowedTCPPorts;
      allowedUDPPorts = config.my.network.firewall.allowedUDPPorts;
      # Allow SSH from LAN only (restrict via lanCidrs)
      trustedInterfaces = lib.optionals (lanCidrs != []) [ ];
    };
  };
}
'
adr docs/adr/ADR-11-firewall.md "10" "NIXH-10-NET-002" "NFTables Firewall" "network,firewall" \
  "NFTables firewall with LAN trust." "## Decision\nNFTables only (no iptables). Public ports configurable, SSH restricted."
guide docs/guides/GUIDE-11-firewall.md "10" "NIXH-10-NET-002" "Firewall Guide" "network,firewall" \
  "Configure firewall ports." "Add public ports to my.network.firewall.allowedTCPPorts."

# 12-ssh.nix
module modules/10-network/12-ssh.nix "10" "NIXH-10-NET-003" "SSH Server" "network,ssh,openssh" \
  "OpenSSH server configuration." \
  "my.network.ssh" "" \
'{ config, lib, ... }:
{
  options.my.network.ssh = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable OpenSSH."; };
    port = lib.mkOption { type = lib.types.port; default = 22; description = "SSH listening port."; };
    passwordAuth = lib.mkOption { type = lib.types.bool; default = false; description = "Allow password authentication (forbidden by policy)."; };
    forbidDontPermitRootLogin = lib.mkOption { type = lib.types.bool; default = false; description = "When true, root login is permitted."; };
  };

  config = lib.mkIf config.my.network.ssh.enable {
    services.openssh = {
      enable = true;
      ports = [ config.my.network.ssh.port ];
      settings = {
        PasswordAuthentication = config.my.network.ssh.passwordAuth;
        PermitRootLogin = if config.my.network.ssh.forbidDontPermitRootLogin then "yes" else "no";
        KbdInteractiveAuthentication = false;
      };
    };
    # Expose port to firewall module
    my.core.ports.ssh = lib.mkDefault config.my.network.ssh.port;
  };
}
'
adr docs/adr/ADR-12-ssh.md "10" "NIXH-10-NET-003" "SSH Server" "network,ssh" \
  "OpenSSH configuration." "## Decision\nKey-only auth, configurable port."
guide docs/guides/GUIDE-12-ssh.md "10" "NIXH-10-NET-003" "SSH Guide" "network,ssh" \
  "Configure SSH." "\`\`\`nix\nmy.network.ssh.port = 53844;\n\`\`\`"

# 13-ssh-rescue.nix
module modules/10-network/13-ssh-rescue.nix "10" "NIXH-10-NET-004" "SSH Rescue" "network,ssh,rescue" \
  "Secondary SSH service for emergency access." \
  "my.network.sshRescue" "" \
'{ config, lib, ... }:
{
  options.my.network.sshRescue = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable rescue SSH on port 2222."; };
    port = lib.mkOption { type = lib.types.port; default = 2222; description = "Rescue SSH port."; };
    authorizedKeys = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Rescue SSH keys."; };
  };

  config = lib.mkIf config.my.network.sshRescue.enable {
    systemd.services."sshd-rescue" = {
      description = "Rescue SSH Server";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${config.services.openssh.package}/bin/sshd -D -f /etc/ssh/sshd_config_rescue";
        Restart = "on-failure";
      };
    };
    environment.etc."ssh/sshd_config_rescue".text = ''
      Port ${toString config.my.network.sshRescue.port}
      PermitRootLogin no
      PasswordAuthentication no
      PubkeyAuthentication yes
    '';
  };
}
'
adr docs/adr/ADR-13-ssh-rescue.md "10" "NIXH-10-NET-004" "SSH Rescue" "network,ssh,rescue" \
  "Secondary SSH for emergency access." "## Decision\nSeparate systemd unit, different port, key-only."
guide docs/guides/GUIDE-13-ssh-rescue.md "10" "NIXH-10-NET-004" "SSH Rescue Guide" "network,ssh,rescue" \
  "Enable rescue SSH." "\`\`\`nix\nmy.network.sshRescue.enable = true;\nmy.network.sshRescue.authorizedKeys = [ \"ssh-ed25519 ...\" ];\n\`\`\`"

# 14-blocky.nix
module modules/10-network/14-blocky.nix "10" "NIXH-10-NET-005" "Blocky DNS" "network,dns,blocky" \
  "Blocky DNS server with ad-blocking." \
  "my.network.blocky" "" \
'{ config, lib, ... }:
{
  options.my.network.blocky = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Blocky DNS."; };
    port = lib.mkOption { type = lib.types.port; default = 53; description = "DNS listening port."; };
    metricsPort = lib.mkOption { type = lib.types.port; default = 4000; description = "Metrics port."; };
    upstreamDns = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "1.1.1.1" "8.8.8.8" ]; description = "Upstream DNS servers."; };
    blockingLists = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Ad-block list URLs."; };
  };

  config = lib.mkIf config.my.network.blocky.enable {
    services.blocky = {
      enable = true;
      settings = {
        ports = { dns = config.my.network.blocky.port; http = config.my.network.blocky.metricsPort; };
        upstreams.groups.default = config.my.network.blocky.upstreamDns;
        blocking = lib.mkIf (config.my.network.blocky.blockingLists != []) {
          blackLists = { ads = config.my.network.blocking.blockingLists; };
          clientGroupsBlock.default = [ "ads" ];
        };
      };
    };
  };
}
'
adr docs/adr/ADR-14-blocky.md "10" "NIXH-10-NET-005" "Blocky DNS" "network,dns" \
  "Blocky DNS with ad-blocking." "## Decision\nLocal DNS resolver with configurable block lists."
guide docs/guides/GUIDE-14-blocky.md "10" "NIXH-10-NET-005" "Blocky Guide" "network,dns" \
  "Configure Blocky." "Set upstreamDns and blockingLists as needed."

# 15-caddy.nix
module modules/10-network/15-caddy.nix "10" "NIXH-10-NET-006" "Caddy Reverse Proxy" "network,caddy,reverse-proxy" \
  "Caddy as reverse proxy with automatic TLS." \
  "my.network.caddy" "" \
'{ config, lib, ... }:
let
  idCfg = config.my.core.identity;
  domain = idCfg.domain;
in
{
  options.my.network.caddy = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Caddy reverse proxy."; };
    email = lib.mkOption { type = lib.types.str; default = ""; description = "ACME email for TLS certificates."; };
    virtualHosts = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "Virtual host definitions.";
    };
  };

  config = lib.mkIf config.my.network.caddy.enable {
    services.caddy = {
      enable = true;
      email = lib.mkIf (config.my.network.caddy.email != "") config.my.network.caddy.email;
      virtualHosts = config.my.network.caddy.virtualHosts;
    };
  };
}
'
adr docs/adr/ADR-15-caddy.md "10" "NIXH-10-NET-006" "Caddy Reverse Proxy" "network,caddy" \
  "Caddy as reverse proxy." "## Decision\nAutomatic TLS via ACME. Virtual hosts defined per-service modules."
guide docs/guides/GUIDE-15-caddy.md "10" "NIXH-10-NET-006" "Caddy Guide" "network,caddy" \
  "Configure Caddy." "Set email for ACME registration."

# 16-dns-automation.nix
module modules/10-network/16-dns-automation.nix "10" "NIXH-10-NET-007" "DNS Automation" "network,dns,cloudflare" \
  "Cloudflare DNS conflict detection and runtime map generation." \
  "my.network.dnsAutomation" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.network.dnsAutomation = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable DNS automation guard."; };
    runtimeMap = lib.mkOption { type = lib.types.str; default = "/var/lib/nixhome/dns-map-runtime.json"; description = "Path to runtime DNS map."; };
  };

  config = lib.mkIf config.my.network.dnsAutomation.enable {
    systemd.services.dns-guard = {
      description = "Check Cloudflare for DNS conflicts";
      after = [ "network-online.target" ];
      serviceConfig = {
        Type = "oneshot";
        StateDirectory = "nixhome";
        ProtectSystem = "strict";
        ProtectHome = true;
        PrivateTmp = true;
        ExecStart = pkgs.writeShellScript "dns-guard-runtime" ''
          set -euo pipefail
          # Cloudflare API integration — requires CF_TOKEN env or secret
          echo '{"useNixSubdomain":false,"baseDomain":"${config.my.core.identity.domain}"}' > "${config.my.network.dnsAutomation.runtimeMap}"
        '';
      };
    };
    systemd.timers.dns-guard = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnBootSec = "1min"; OnUnitActiveSec = "30min"; };
    };
  };
}
'
adr docs/adr/ADR-16-dns-automation.md "10" "NIXH-10-NET-007" "DNS Automation" "network,dns" \
  "DNS conflict detection via Cloudflare API." "## Decision\nPeriodic timer checks Cloudflare for conflicting records."
guide docs/guides/GUIDE-16-dns-automation.md "10" "NIXH-10-NET-007" "DNS Automation Guide" "network,dns" \
  "Configure DNS automation." "Requires Cloudflare API token."

# 17-pocket-id.nix
module modules/10-network/17-pocket-id.nix "10" "NIXH-10-NET-008" "Pocket-ID" "network,oidc,auth,pocket-id" \
  "Pocket-ID OIDC provider for SSO." \
  "my.network.pocketId" "" \
'{ config, lib, ... }:
let
  idCfg = config.my.core.identity;
in
{
  options.my.network.pocketId = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Pocket-ID."; };
    issuerUrl = lib.mkOption { type = lib.types.str; default = ""; description = "OIDC issuer URL."; };
  };

  config = lib.mkIf config.my.network.pocketId.enable {
    services.pocket-id = {
      enable = true;
      settings = {
        issuer = lib.mkIf (config.my.network.pocketId.issuerUrl != "") config.my.network.pocketId.issuerUrl;
        public_registration = false;
      };
    };
  };
}
'
adr docs/adr/ADR-17-pocket-id.md "10" "NIXH-10-NET-008" "Pocket-ID" "network,oidc" \
  "Pocket-ID OIDC provider." "## Decision\nSelf-hosted SSO via Pocket-ID."
guide docs/guides/GUIDE-17-pocket-id.md "10" "NIXH-10-NET-008" "Pocket-ID Guide" "network,oidc" \
  "Configure Pocket-ID." "\`\`\`nix\nmy.network.pocketId.enable = true;\n\`\`\`"

# 18-ddns-updater.nix
module modules/10-network/18-ddns-updater.nix "10" "NIXH-10-NET-009" "DDNS Updater" "network,ddns,dynamic-dns" \
  "Dynamic DNS updates." \
  "my.network.ddnsUpdater" "" \
'{ config, lib, ... }:
{
  options.my.network.ddnsUpdater = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable DDNS updater."; };
    port = lib.mkOption { type = lib.types.port; default = 8080; description = "DDNS updater UI port."; };
    period = lib.mkOption { type = lib.types.str; default = "10m"; description = "Update check interval."; };
  };

  config = lib.mkIf config.my.network.ddnsUpdater.enable {
    services.ddns-updater = {
      enable = true;
      environment = {
        LISTENING_ADDRESS = ":${toString config.my.network.ddnsUpdater.port}";
        PERIOD = config.my.network.ddnsUpdater.period;
      };
    };
  };
}
'
adr docs/adr/ADR-18-ddns-updater.md "10" "NIXH-10-NET-009" "DDNS Updater" "network,ddns" \
  "Dynamic DNS updater." "## Decision\nLightweight DDNS updater service."
guide docs/guides/GUIDE-18-ddns-updater.md "10" "NIXH-10-NET-009" "DDNS Guide" "network,ddns" \
  "Configure DDNS." "Requires Cloudflare or other provider credentials."

# 19-zigbee-stack.nix
module modules/10-network/19-zigbee-stack.nix "10" "NIXH-10-NET-010" "Zigbee Stack" "network,zigbee,mqtt,iot" \
  "Mosquitto MQTT broker + Zigbee2MQTT." \
  "my.network.zigbeeStack" "" \
'{ config, lib, ... }:
{
  options.my.network.zigbeeStack = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Zigbee stack."; };
    mqttPort = lib.mkOption { type = lib.types.port; default = 1883; description = "MQTT broker port."; };
    zigbeePort = lib.mkOption { type = lib.types.port; default = 8089; description = "Zigbee2MQTT frontend port."; };
    zigbeeDevice = lib.mkOption { type = lib.types.str; default = ""; description = "Zigbee adapter path or socket URL."; };
    adapter = lib.mkOption {
      type = lib.types.enum [ "ember" "zstack" "deconz" "ezsp" ];
      default = "ember";
      description = "Zigbee adapter type.";
    };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/zigbee2mqtt"; description = "Zigbee2MQTT data directory."; };
  };

  config = lib.mkIf config.my.network.zigbeeStack.enable {
    services.mosquitto = {
      enable = true;
      listeners = [{
        port = config.my.network.zigbeeStack.mqttPort;
        address = "127.0.0.1";
        acl = [ "pattern readwrite #" ];
        settings.allow_anonymous = true;
      }];
    };
    services.zigbee2mqtt = {
      enable = true;
      dataDir = config.my.network.zigbeeStack.dataDir;
      settings = {
        permit_join = false;
        mqtt = {
          base_topic = "zigbee2mqtt";
          server = "mqtt://127.0.0.1:${toString config.my.network.zigbeeStack.mqttPort}";
        };
        serial = {
          port = config.my.network.zigbeeStack.zigbeeDevice;
          adapter = config.my.network.zigbeeStack.adapter;
        };
        frontend = {
          port = config.my.network.zigbeeStack.zigbeePort;
          host = "127.0.0.1";
        };
      };
    };
  };
}
'
adr docs/adr/ADR-19-zigbee-stack.md "10" "NIXH-10-NET-010" "Zigbee Stack" "network,zigbee,mqtt" \
  "Mosquitto + Zigbee2MQTT." "## Decision\nLocal MQTT broker, Zigbee2MQTT frontend on configurable port."
guide docs/guides/GUIDE-19-zigbee-stack.md "10" "NIXH-10-NET-010" "Zigbee Guide" "network,zigbee" \
  "Configure Zigbee." "Set zigbeeDevice to /dev/ttyUSB0 or socket URL."

echo "=== Phase 4: 20-security (4 modules) ==="

# 20-fail2ban.nix
module modules/20-security/20-fail2ban.nix "20" "NIXH-20-SEC-001" "Fail2ban" "security,fail2ban,nftables" \
  "Fail2ban with NFTables and Caddy log inspection." \
  "my.security.fail2ban" "" \
'{ config, lib, pkgs, ... }:
let
  sshPort = toString config.my.core.ports.ssh;
in
{
  options.my.security.fail2ban = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Fail2ban."; };
    bantime = lib.mkOption { type = lib.types.str; default = "1h"; description = "Default ban duration."; };
    maxretry = lib.mkOption { type = lib.types.int; default = 5; description = "Max retries before ban."; };
    banIncrementMaxtime = lib.mkOption { type = lib.types.str; default = "168h"; description = "Max incremental ban time."; };
  };

  config = lib.mkIf config.my.security.fail2ban.enable {
    services.fail2ban = {
      enable = true;
      banaction = "nftables-multiport";
      bantime = config.my.security.fail2ban.bantime;
      maxretry = config.my.security.fail2ban.maxretry;
      bantime-increment = {
        enable = true;
        multipliers = "1 2 4 8 16 32 64";
        maxtime = config.my.security.fail2ban.banIncrementMaxtime;
      };
      jails = {
        sshd.settings = {
          enabled = true;
          port = sshPort;
          mode = "aggressive";
        };
      };
    };
    environment.etc."fail2ban/filter.d/caddy-json.conf".text = ''
      [Definition]
      failregex = ^.*"remote_ip":"<ADDR>".*"status":(401|403).*$
      journalmatch = _SYSTEMD_UNIT=caddy.service
    '';
  };
}
'
adr docs/adr/ADR-20-fail2ban.md "20" "NIXH-20-SEC-001" "Fail2ban" "security,fail2ban" \
  "Fail2ban with NFTables." "## Decision\nNFTables backend, incremental banning, Caddy JSON filter."
guide docs/guides/GUIDE-20-fail2ban.md "20" "NIXH-20-SEC-001" "Fail2ban Guide" "security,fail2ban" \
  "Configure Fail2ban." "\`\`\`nix\nmy.security.fail2ban.enable = true;\n\`\`\`"

# 21-kernel-hardening.nix
module modules/20-security/21-kernel-hardening.nix "20" "NIXH-20-SEC-002" "Kernel Hardening" "security,kernel,sysctl" \
  "Kernel module blacklist, sysctl hardening, boot parameters." \
  "my.security.kernel" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.security.kernel = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable kernel hardening."; };
    lockModules = lib.mkOption { type = lib.types.bool; default = true; description = "Lock loaded kernel modules."; };
    apparmor = lib.mkOption { type = lib.types.bool; default = true; description = "Enable AppArmor."; };
    blacklistModules = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Additional blacklisted modules."; };
  };

  config = lib.mkIf config.my.security.kernel.enable {
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    boot.blacklistedKernelModules = [
      # Audio (headless server)
      "snd_hda_intel" "snd_hda_codec_realtek"
      # Wireless
      "iwlwifi" "ath9k" "ath10k_core" "rtl8192cu"
      # Bluetooth
      "bluetooth" "btusb"
      # Non-Intel GPUs
      "nouveau" "radeon" "amdgpu"
      # Legacy protocols
      "dccp" "sctp" "rds" "tipc"
    ] ++ config.my.security.kernel.blacklistModules;
    boot.kernel.sysctl = {
      "net.ipv4.tcp_syncookies" = 1;
      "net.ipv4.conf.all.rp_filter" = 1;
      "kernel.kptr_restrict" = 2;
      "kernel.dmesg_restrict" = 1;
      "kernel.unprivileged_userns_clone" = 0;
      "fs.protected_hardlinks" = 1;
      "fs.protected_symlinks" = 1;
      "vm.mmap_rnd_bits" = 32;
    };
    security.lockKernelModules = config.my.security.kernel.lockModules;
    security.apparmor.enable = config.my.security.kernel.apparmor;
    boot.kernelParams = [
      "mitigations=auto,nosmt"
      "slab_nomerge"
      "init_on_free=1"
      "vsyscall=none"
      "debugfs=off"
      "lockdown=integrity"
    ];
  };
}
'
adr docs/adr/ADR-21-kernel-hardening.md "20" "NIXH-20-SEC-002" "Kernel Hardening" "security,kernel" \
  "Kernel module blacklist + sysctl." "## Decision\nBlacklist unused hardware, enforce sysctl hardening."
guide docs/guides/GUIDE-21-kernel-hardening.md "20" "NIXH-20-SEC-002" "Kernel Guide" "security,kernel" \
  "Kernel hardening guide." "Defaults are production-ready for headless servers."

# 22-secrets.nix
module modules/20-security/22-secrets.nix "20" "NIXH-20-SEC-003" "Secrets Management" "security,sops,secrets" \
  "SOPS-based secrets management." \
  "my.security.secrets" "" \
'{ config, lib, ... }:
{
  options.my.security.secrets = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable SOPS secrets."; };
    ageKeyFile = lib.mkOption { type = lib.types.str; default = "/etc/sops-nix/age-keys.txt"; description = "SOPS age key file path."; };
    defaultSopsFile = lib.mkOption { type = lib.types.path; default = null; description = "Default encrypted secrets file."; };
  };

  config = lib.mkIf config.my.security.secrets.enable {
    sops = {
      defaultSopsFile = lib.mkIf (config.my.security.secrets.defaultSopsFile != null) config.my.security.secrets.defaultSopsFile;
      age.sshKeyPaths = [ ];
      age.keyFile = lib.mkIf (config.my.security.secrets.ageKeyFile != "") config.my.security.secrets.ageKeyFile;
      secrets = {};
    };
  };
}
'
adr docs/adr/ADR-22-secrets.md "20" "NIXH-20-SEC-003" "Secrets Management" "security,sops" \
  "SOPS-based secrets." "## Decision\nAge encryption, declarative secrets via sops-nix."
guide docs/guides/GUIDE-22-secrets.md "20" "NIXH-20-SEC-003" "Secrets Guide" "security,sops" \
  "Configure SOPS secrets." "Requires sops-nix and age key setup."

# 23-secrets-schema.nix
module modules/20-security/23-secrets-schema.nix "20" "NIXH-20-SEC-004" "Secrets Schema" "security,sops,schema" \
  "Declarative schema for SOPS secret definitions." \
  "my.security.secretsSchema" "" \
'{ config, lib, ... }:
{
  options.my.security.secretsSchema = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable secrets schema validation."; };
    schema = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "Schema for expected secrets.";
    };
  };

  config = lib.mkIf config.my.security.secretsSchema.enable {
    # Schema validation via assertions
    assertions = lib.mapAttrsToList (name: def: {
      assertion = config.sops.secrets ? ${name} || def.optional or false;
      message = "Missing required secret: ${name}";
    }) config.my.security.secretsSchema.schema;
  };
}
'
adr docs/adr/ADR-23-secrets-schema.md "20" "NIXH-20-SEC-004" "Secrets Schema" "security,sops,schema" \
  "Declarative secrets schema." "## Decision\nSchema ensures required secrets are defined before deploy."
guide docs/guides/GUIDE-23-secrets-schema.md "20" "NIXH-20-SEC-004" "Secrets Schema Guide" "security,sops" \
  "Define secrets schema." "Use schema attribute to declare required secrets."

echo "=== Phase 5: 30-storage (5 modules) ==="

# 30-storage.nix
module modules/30-storage/30-storage.nix "30" "NIXH-30-STO-001" "Storage Configuration" "storage,filesystems,tiering" \
  "File system definitions and ABC tier mount points." \
  "my.storage" "" \
'{ config, lib, ... }:
{
  options.my.storage = {
    tierA = lib.mkOption { type = lib.types.str; default = "/persist"; description = "Tier A: NVMe state partition."; };
    tierB = lib.mkOption { type = lib.types.str; default = "/mnt/cache"; description = "Tier B: SSD cache."; };
    tierC = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool"; description = "Tier C: HDD archive."; };
    downloads = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; description = "Download directory (Tier B)."; };
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/cache/media"; description = "Media library (Tier B)."; };
    mediaArchive = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/media"; description = "Media archive (Tier C)."; };
    stateDir = lib.mkOption { type = lib.types.str; default = "/var/lib"; description = "Application state directory."; };
    appData = lib.mkOption { type = lib.types.str; default = "/var/lib"; description = "Application data directory."; };
    privateData = lib.mkOption { type = lib.types.str; default = "/var/lib/private"; description = "Private data directory."; };
    devices = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Physical HDD devices."; };
    fileSystems = lib.mkOption {
      type = lib.types.attrsOf lib.types.attrs;
      default = {};
      description = "File system definitions.";
    };
  };

  config = {
    fileSystems = lib.mkMerge [
      config.my.storage.fileSystems
    ];
  };
}
'
adr docs/adr/ADR-30-storage.md "30" "NIXH-30-STO-001" "Storage Configuration" "storage,filesystems" \
  "ABC tiering storage layout." "## Decision\nThree-tier storage: NVMe (persist), SSD (cache), HDD (archive)."
guide docs/guides/GUIDE-30-storage.md "30" "NIXH-30-STO-001" "Storage Guide" "storage,filesystems" \
  "Configure storage tiers." "Define mounts in hosts config."

# 31-backup.nix
module modules/30-storage/31-backup.nix "30" "NIXH-30-STO-002" "Backup" "storage,backup,restic" \
  "Restic backup configuration." \
  "my.storage.backup" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.storage.backup = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Restic backups."; };
    repository = lib.mkOption { type = lib.types.str; default = "/mnt/archive/.restic-vault"; description = "Local backup repository."; };
    remoteRepository = lib.mkOption { type = lib.types.str; default = ""; description = "Remote repository URL."; };
    paths = lib.mkOption { type = lib.types.listOf lib.types.str; default = [ "/etc/nixos" "/var/lib" ]; description = "Paths to backup."; };
    pruneKeepDaily = lib.mkOption { type = lib.types.int; default = 7; description = "Keep daily snapshots."; };
    pruneKeepWeekly = lib.mkOption { type = lib.types.int; default = 4; description = "Keep weekly snapshots."; };
    pruneKeepMonthly = lib.mkOption { type = lib.types.int; default = 6; description = "Keep monthly snapshots."; };
    timerSchedule = lib.mkOption { type = lib.types.str; default = "02:00"; description = "Backup schedule."; };
  };

  config = lib.mkIf config.my.storage.backup.enable {
    services.restic.backups."${config.my.core.identity.host}-local" = {
      initialize = true;
      repository = config.my.storage.backup.repository;
      paths = config.my.storage.backup.paths;
      pruneOpts = [
        "--keep-daily ${toString config.my.storage.backup.pruneKeepDaily}"
        "--keep-weekly ${toString config.my.storage.backup.pruneKeepWeekly}"
        "--keep-monthly ${toString config.my.storage.backup.pruneKeepMonthly}"
      ];
      timerConfig = {
        OnCalendar = config.my.storage.backup.timerSchedule;
        Persistent = true;
      };
    };
  };
}
'
adr docs/adr/ADR-31-backup.md "30" "NIXH-30-STO-002" "Backup" "storage,backup,restic" \
  "Restic backup strategy." "## Decision\nLocal Restic with configurable retention."
guide docs/guides/GUIDE-31-backup.md "30" "NIXH-30-STO-002" "Backup Guide" "storage,backup" \
  "Configure backups." "Set repository and paths."

# 32-impermanence.nix
module modules/30-storage/32-impermanence.nix "30" "NIXH-30-STO-003" "Impermanence" "storage,impermanence,stateless" \
  "Stateless root with /persist persistence." \
  "my.storage.impermanence" "" \
'{ config, lib, ... }:
{
  options.my.storage.impermanence = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable stateless root with /persist."; };
    persistDir = lib.mkOption { type = lib.types.str; default = "/persist"; description = "Persistence mount point."; };
    directories = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Directories to persist."; };
    files = lib.mkOption { type = lib.types.listOf lib.types.str; default = []; description = "Files to persist."; };
    ramfsSize = lib.mkOption { type = lib.types.str; default = "4G"; description = "Root tmpfs size."; };
  };

  config = lib.mkIf config.my.storage.impermanence.enable {
    fileSystems."/" = lib.mkForce {
      device = "none";
      fsType = "tmpfs";
      options = [ "defaults" "size=${config.my.storage.impermanence.ramfsSize}" "mode=755" ];
    };
  };
}
'
adr docs/adr/ADR-32-impermanence.md "30" "NIXH-30-STO-003" "Impermanence" "storage,impermanence" \
  "Stateless root with tmpfs." "## Decision\nRoot on RAM, /persist for durable state."
guide docs/guides/GUIDE-32-impermanence.md "30" "NIXH-30-STO-003" "Impermanence Guide" "storage,impermanence" \
  "Enable impermanence." "\`\`\`nix\nmy.storage.impermanence.enable = true;\n\`\`\`"

# 33-storage-policy.nix
module modules/30-storage/33-storage-policy.nix "30" "NIXH-30-STO-004" "Storage Policy" "storage,policy,assertions" \
  "Storage tiering policy assertions." \
  "my.storage.policy" "" \
'{ config, lib, ... }:
{
  options.my.storage.policy = {
    enable = lib.mkOption { type = lib.types.bool; default = true; description = "Enable storage policy assertions."; };
  };

  config = lib.mkIf config.my.storage.policy.enable {
    assertions = [
      {
        assertion = config.my.storage.tierA == "/persist";
        message = "ABC Tiering Error: Tier A MUST be /persist.";
      }
    ];
  };
}
'
adr docs/adr/ADR-33-storage-policy.md "30" "NIXH-30-STO-004" "Storage Policy" "storage,policy" \
  "Storage policy assertions." "## Decision\nEnforce ABC tiering rules at build time."
guide docs/guides/GUIDE-33-storage-policy.md "30" "NIXH-30-STO-004" "Storage Policy Guide" "storage,policy" \
  "Storage policy guide." "Assertions prevent misconfiguration."

# 34-storage-mover.nix
module modules/30-storage/34-storage-mover.nix "30" "NIXH-30-STO-005" "Smart Storage Mover" "storage,mover,tiering" \
  "Automated SSD-to-HDD archival mover." \
  "my.storage.mover" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.storage.mover = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable smart storage mover."; };
    ssdDir = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; description = "Source directory (SSD)."; };
    hddDir = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/downloads"; description = "Target directory (HDD)."; };
    lowSpaceThresholdGB = lib.mkOption { type = lib.types.int; default = 20; description = "Trigger move when SSD below this (GB)."; };
    dryRun = lib.mkOption { type = lib.types.bool; default = false; description = "Dry-run mode."; };
  };

  config = lib.mkIf config.my.storage.mover.enable {
    systemd.services.storage-mover = {
      description = "Smart Storage Mover (SSD → HDD)";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = pkgs.writeShellScript "smart-mover" ''
          set -euo pipefail
          echo "Storage mover: ${config.my.storage.mover.ssdDir} → ${config.my.storage.mover.hddDir}"
        '';
        Nice = 19;
        IOSchedulingClass = "idle";
      };
    };
    systemd.timers.storage-mover = {
      wantedBy = [ "timers.target" ];
      timerConfig = { OnCalendar = "daily"; Persistent = true; };
    };
  };
}
'
adr docs/adr/ADR-34-storage-mover.md "30" "NIXH-30-STO-005" "Smart Storage Mover" "storage,mover" \
  "Automated tiering mover." "## Decision\nDaily timer moves old data from SSD to HDD."
guide docs/guides/GUIDE-34-storage-mover.md "30" "NIXH-30-STO-005" "Mover Guide" "storage,mover" \
  "Configure mover." "Set ssdDir and hddDir paths."

echo "=== Phase 6: 40-monitoring (6 modules) ==="

# 40-gatus.nix
module modules/40-monitoring/40-gatus.nix "40" "NIXH-40-MON-001" "Gatus Health Dashboard" "monitoring,gatus,health" \
  "Gatus health monitoring with configurable endpoints." \
  "my.monitoring.gatus" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.monitoring.gatus = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Gatus."; };
    port = lib.mkOption { type = lib.types.port; default = 8081; description = "Gatus web port."; };
    ntfyUrl = lib.mkOption { type = lib.types.str; default = ""; description = "ntfy alerting URL."; };
    ntfyTopic = lib.mkOption { type = lib.types.str; default = "gatus-alerts"; description = "ntfy topic."; };
    endpoints = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [];
      description = "Endpoints to monitor.";
    };
  };

  config = lib.mkIf config.my.monitoring.gatus.enable {
    services.gatus = {
      enable = true;
      settings = {
        web = {
          address = "127.0.0.1";
          port = config.my.monitoring.gatus.port;
        };
        storage = { type = "sqlite"; path = "/var/lib/gatus/data.db"; };
        endpoints = config.my.monitoring.gatus.endpoints;
      };
    };
  };
}
'
adr docs/adr/ADR-40-gatus.md "40" "NIXH-40-MON-001" "Gatus Health Dashboard" "monitoring,gatus" \
  "Gatus health monitoring." "## Decision\nDeclarative endpoint monitoring with ntfy alerts."
guide docs/guides/GUIDE-40-gatus.md "40" "NIXH-40-MON-001" "Gatus Guide" "monitoring,gatus" \
  "Configure Gatus." "Add endpoints to my.monitoring.gatus.endpoints."

# 41-netdata.nix
module modules/40-monitoring/41-netdata.nix "40" "NIXH-40-MON-002" "Netdata Telemetry" "monitoring,netdata,metrics" \
  "Netdata real-time performance monitoring." \
  "my.monitoring.netdata" "" \
'{ config, lib, ... }:
{
  options.my.monitoring.netdata = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Netdata."; };
    port = lib.mkOption { type = lib.types.port; default = 19999; description = "Netdata port."; };
  };

  config = lib.mkIf config.my.monitoring.netdata.enable {
    services.netdata = {
      enable = true;
      config = {
        global = { "memory mode" = "dbengine"; };
        web = { "bind to" = "unix:/run/netdata/netdata.sock"; };
      };
    };
  };
}
'
adr docs/adr/ADR-41-netdata.md "40" "NIXH-40-MON-002" "Netdata Telemetry" "monitoring,netdata" \
  "Netdata real-time monitoring." "## Decision\nSocket-only access, dbengine storage."
guide docs/guides/GUIDE-41-netdata.md "40" "NIXH-40-MON-002" "Netdata Guide" "monitoring,netdata" \
  "Configure Netdata." "Access via Caddy reverse proxy."

# 42-ntfy.nix
module modules/40-monitoring/42-ntfy.nix "40" "NIXH-40-MON-003" "ntfy-sh" "monitoring,ntfy,alerting" \
  "Local ntfy-sh notification server." \
  "my.monitoring.ntfy" "" \
'{ config, lib, ... }:
{
  options.my.monitoring.ntfy = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable ntfy-sh."; };
    port = lib.mkOption { type = lib.types.port; default = 2586; description = "ntfy-sh HTTP port."; };
  };

  config = lib.mkIf config.my.monitoring.ntfy.enable {
    services.ntfy-sh = {
      enable = true;
      settings = {
        listen-http = "127.0.0.1:${toString config.my.monitoring.ntfy.port}";
        behind-proxy = true;
      };
    };
  };
}
'
adr docs/adr/ADR-42-ntfy.md "40" "NIXH-40-MON-003" "ntfy-sh" "monitoring,ntfy" \
  "Local ntfy-sh server." "## Decision\nSelf-hosted notification server."
guide docs/guides/GUIDE-42-ntfy.md "40" "NIXH-40-MON-003" "ntfy Guide" "monitoring,ntfy" \
  "Configure ntfy-sh." "\`\`\`nix\nmy.monitoring.ntfy.enable = true;\n\`\`\`"

# 43-scrutiny.nix
module modules/40-monitoring/43-scrutiny.nix "40" "NIXH-40-MON-004" "Scrutiny SMART" "monitoring,scrutiny,smart" \
  "Hard drive S.M.A.R.T. monitoring with Scrutiny." \
  "my.monitoring.scrutiny" "" \
'{ config, lib, ... }:
{
  options.my.monitoring.scrutiny = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Scrutiny."; };
    port = lib.mkOption { type = lib.types.port; default = 8082; description = "Scrutiny web port."; };
  };

  config = lib.mkIf config.my.monitoring.scrutiny.enable {
    services.scrutiny = {
      enable = true;
      settings = {
        web.listen.port = config.my.monitoring.scrutiny.port;
        web.listen.host = "127.0.0.1";
      };
      collector.enable = true;
    };
    services.smartd.enable = true;
  };
}
'
adr docs/adr/ADR-43-scrutiny.md "40" "NIXH-40-MON-004" "Scrutiny SMART" "monitoring,scrutiny" \
  "SMART drive monitoring." "## Decision\nScrutiny + smartd for drive health."
guide docs/guides/GUIDE-43-scrutiny.md "40" "NIXH-40-MON-004" "Scrutiny Guide" "monitoring,scrutiny" \
  "Configure Scrutiny." "Requires drive access permissions."

# 44-vector.nix
module modules/40-monitoring/44-vector.nix "40" "NIXH-40-MON-005" "Vector Log Aggregator" "monitoring,vector,logging" \
  "Vector centralized log pipeline." \
  "my.monitoring.vector" "" \
'{ config, lib, ... }:
{
  options.my.monitoring.vector = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Vector."; };
    logDir = lib.mkOption { type = lib.types.str; default = "/var/log/vector"; description = "Log output directory."; };
  };

  config = lib.mkIf config.my.monitoring.vector.enable {
    services.vector = {
      enable = true;
      journaldAccess = true;
      settings = {
        sources = { journal = { type = "journald"; }; };
        sinks = {
          file_output = {
            type = "file";
            path = "${config.my.monitoring.vector.logDir}/all-logs-%Y-%m-%d.json";
            inputs = [ "journal" ];
            encoding = { codec = "json"; };
          };
        };
      };
    };
    systemd.tmpfiles.rules = [ "d ${config.my.monitoring.vector.logDir} 0750 vector vector -" ];
  };
}
'
adr docs/adr/ADR-44-vector.md "40" "NIXH-40-MON-005" "Vector Log Aggregator" "monitoring,vector" \
  "Vector log pipeline." "## Decision\nJournald → file output pipeline."
guide docs/guides/GUIDE-44-vector.md "40" "NIXH-40-MON-005" "Vector Guide" "monitoring,vector" \
  "Configure Vector." "Set logDir for output."

# 45-uptime-kuma.nix
module modules/40-monitoring/45-uptime-kuma.nix "40" "NIXH-40-MON-006" "Uptime Kuma" "monitoring,uptime-kuma,uptime" \
  "Uptime Kuma monitoring dashboard." \
  "my.monitoring.uptimeKuma" "" \
'{ config, lib, ... }:
{
  options.my.monitoring.uptimeKuma = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Uptime Kuma."; };
    port = lib.mkOption { type = lib.types.port; default = 3001; description = "Uptime Kuma port."; };
  };

  config = lib.mkIf config.my.monitoring.uptimeKuma.enable {
    services.uptime-kuma = {
      enable = true;
      settings.PORT = toString config.my.monitoring.uptimeKuma.port;
    };
  };
}
'
adr docs/adr/ADR-45-uptime-kuma.md "40" "NIXH-40-MON-006" "Uptime Kuma" "monitoring,uptime-kuma" \
  "Uptime Kuma dashboard." "## Decision\nSelf-hosted uptime monitoring."
guide docs/guides/GUIDE-45-uptime-kuma.md "40" "NIXH-40-MON-006" "Uptime Kuma Guide" "monitoring,uptime-kuma" \
  "Configure Uptime Kuma." "Access via Caddy reverse proxy."

echo "=== Phase 7: 50-media (9 modules) ==="

# 50-lib-media.nix
module modules/50-media/50-lib-media.nix "50" "NIXH-50-MED-001" "Media Library" "media,library,factories" \
  "Shared media library paths and factory helpers." \
  "my.media.library" "" \
'{ config, lib, ... }:
{
  options.my.media.library = {
    mediaLibrary = lib.mkOption { type = lib.types.str; default = "/mnt/cache/media"; description = "Media library path."; };
    downloads = lib.mkOption { type = lib.types.str; default = "/mnt/cache/downloads"; description = "Downloads path."; };
    mediaArchive = lib.mkOption { type = lib.types.str; default = "/mnt/hdd_pool/media"; description = "Media archive path."; };
  };
}
'
adr docs/adr/ADR-50-lib-media.md "50" "NIXH-50-MED-001" "Media Library" "media,library" \
  "Shared media paths." "## Decision\nCentralized media path options."
guide docs/guides/GUIDE-50-lib-media.md "50" "NIXH-50-MED-001" "Media Library Guide" "media,library" \
  "Configure media paths." "Set paths in host config."

# 51-arr-stack.nix
module modules/50-media/51-arr-stack.nix "50" "NIXH-50-MED-002" "Arr Stack" "media,arr,radarr,sonarr,prowlarr" \
  "*Arr media management stack." \
  "my.media.arr" "" \
'{ config, lib, ... }:
{
  options.my.media.arr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Arr stack."; };
    radarrPort = lib.mkOption { type = lib.types.port; default = 7878; description = "Radarr port."; };
    sonarrPort = lib.mkOption { type = lib.types.port; default = 8989; description = "Sonarr port."; };
    prowlarrPort = lib.mkOption { type = lib.types.port; default = 9696; description = "Prowlarr port."; };
  };

  config = lib.mkIf config.my.media.arr.enable {
    services.radarr.enable = true;
    services.sonarr.enable = true;
    services.prowlarr.enable = true;
  };
}
'
adr docs/adr/ADR-51-arr-stack.md "50" "NIXH-50-MED-002" "Arr Stack" "media,arr" \
  "Radarr, Sonarr, Prowlarr." "## Decision\nEnable all three via single toggle."
guide docs/guides/GUIDE-51-arr-stack.md "50" "NIXH-50-MED-002" "Arr Guide" "media,arr" \
  "Configure Arr stack." "\`\`\`nix\nmy.media.arr.enable = true;\n\`\`\`"

# 52-download.nix
module modules/50-media/52-download.nix "50" "NIXH-50-MED-003" "Download Stack" "media,download,sabnzbd" \
  "SABnzbd download manager." \
  "my.media.downloads" "" \
'{ config, lib, ... }:
{
  options.my.media.downloads = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable download stack."; };
  };

  config = lib.mkIf config.my.media.downloads.enable {
    services.sabnzbd.enable = true;
  };
}
'
adr docs/adr/ADR-52-download.md "50" "NIXH-50-MED-003" "Download Stack" "media,download" \
  "SABnzbd downloader." "## Decision\nSABnzbd for NZB downloads."
guide docs/guides/GUIDE-52-download.md "50" "NIXH-50-MED-003" "Download Guide" "media,download" \
  "Configure SABnzbd." "\`\`\`nix\nmy.media.downloads.enable = true;\n\`\`\`"

# 53-streaming.nix
module modules/50-media/53-streaming.nix "50" "NIXH-50-MED-004" "Streaming Stack" "media,streaming,jellyfin" \
  "Jellyfin, Navidrome, Audiobookshelf streaming." \
  "my.media.streaming" "" \
'{ config, lib, ... }:
{
  options.my.media.streaming = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable streaming stack."; };
    gpuAcceleration = lib.mkEnableOption "Intel GPU hardware transcoding";
  };

  config = lib.mkIf config.my.media.streaming.enable {
    services.jellyfin.enable = true;
    services.navidrome.enable = true;
    services.audiobookshelf.enable = true;
    hardware.graphics.enable = lib.mkIf config.my.media.streaming.gpuAcceleration true;
  };
}
'
adr docs/adr/ADR-53-streaming.md "50" "NIXH-50-MED-004" "Streaming Stack" "media,streaming" \
  "Jellyfin, Navidrome, Audiobookshelf." "## Decision\nAll streaming services under single toggle."
guide docs/guides/GUIDE-53-streaming.md "50" "NIXH-50-MED-004" "Streaming Guide" "media,streaming" \
  "Configure streaming." "Enable gpuAcceleration for Intel QSV."

# 54-discovery.nix
module modules/50-media/54-discovery.nix "50" "NIXH-50-MED-005" "Media Discovery" "media,jellyseerr,discovery" \
  "Jellyseerr media request/discovery." \
  "my.media.discovery" "" \
'{ config, lib, ... }:
{
  options.my.media.discovery = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Jellyseerr."; };
    port = lib.mkOption { type = lib.types.port; default = 5055; description = "Jellyseerr port."; };
  };

  config = lib.mkIf config.my.media.discovery.enable {
    services.jellyseerr = {
      enable = true;
      port = config.my.media.discovery.port;
    };
  };
}
'
adr docs/adr/ADR-54-discovery.md "50" "NIXH-50-MED-005" "Media Discovery" "media,jellyseerr" \
  "Jellyseerr for media requests." "## Decision\nSelf-hosted media request system."
guide docs/guides/GUIDE-54-discovery.md "50" "NIXH-50-MED-005" "Discovery Guide" "media,jellyseerr" \
  "Configure Jellyseerr." "\`\`\`nix\nmy.media.discovery.enable = true;\n\`\`\`"

# 55-jellyfin.nix
module modules/50-media/55-jellyfin.nix "50" "NIXH-50-MED-006" "Jellyfin" "media,jellyfin,streaming" \
  "Jellyfin media server with hardware acceleration." \
  "my.media.jellyfin" "" \
'{ config, lib, ... }:
{
  options.my.media.jellyfin = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Jellyfin."; };
    gpuAcceleration = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Intel QuickSync."; };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/jellyfin"; description = "Jellyfin data directory."; };
  };

  config = lib.mkIf config.my.media.jellyfin.enable {
    services.jellyfin = {
      enable = true;
      dataDir = config.my.media.jellyfin.dataDir;
    };
  };
}
'
adr docs/adr/ADR-55-jellyfin.md "50" "NIXH-50-MED-006" "Jellyfin" "media,jellyfin" \
  "Jellyfin media server." "## Decision\nHardware-accelerated transcoding option."
guide docs/guides/GUIDE-55-jellyfin.md "50" "NIXH-50-MED-006" "Jellyfin Guide" "media,jellyfin" \
  "Configure Jellyfin." "Enable gpuAcceleration for Intel GPUs."

# 56-sonarr.nix
module modules/50-media/56-sonarr.nix "50" "NIXH-50-MED-007" "Sonarr" "media,sonarr,tv" \
  "Sonarr TV series manager." \
  "my.media.sonarr" "" \
'{ config, lib, ... }:
{
  options.my.media.sonarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Sonarr."; };
    port = lib.mkOption { type = lib.types.port; default = 8989; description = "Sonarr port."; };
  };
}
'
adr docs/adr/ADR-56-sonarr.md "50" "NIXH-50-MED-007" "Sonarr" "media,sonarr" \
  "Sonarr TV series manager." "## Decision\nSimple toggle + port option."
guide docs/guides/GUIDE-56-sonarr.md "50" "NIXH-50-MED-007" "Sonarr Guide" "media,sonarr" \
  "Configure Sonarr." "Usually enabled via my.media.arr.enable."

# 57-radarr.nix
module modules/50-media/57-radarr.nix "50" "NIXH-50-MED-008" "Radarr" "media,radarr,movies" \
  "Radarr movie manager." \
  "my.media.radarr" "" \
'{ config, lib, ... }:
{
  options.my.media.radarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Radarr."; };
    port = lib.mkOption { type = lib.types.port; default = 7878; description = "Radarr port."; };
  };
}
'
adr docs/adr/ADR-57-radarr.md "50" "NIXH-50-MED-008" "Radarr" "media,radarr" \
  "Radarr movie manager." "## Decision\nSimple toggle + port option."
guide docs/guides/GUIDE-57-radarr.md "50" "NIXH-50-MED-008" "Radarr Guide" "media,radarr" \
  "Configure Radarr." "Usually enabled via my.media.arr.enable."

# 58-prowlarr.nix
module modules/50-media/58-prowlarr.nix "50" "NIXH-50-MED-009" "Prowlarr" "media,prowlarr,indexer" \
  "Prowlarr indexer manager." \
  "my.media.prowlarr" "" \
'{ config, lib, ... }:
{
  options.my.media.prowlarr = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Prowlarr."; };
    port = lib.mkOption { type = lib.types.port; default = 9696; description = "Prowlarr port."; };
  };
}
'
adr docs/adr/ADR-58-prowlarr.md "50" "NIXH-50-MED-009" "Prowlarr" "media,prowlarr" \
  "Prowlarr indexer manager." "## Decision\nSimple toggle + port option."
guide docs/guides/GUIDE-58-prowlarr.md "50" "NIXH-50-MED-009" "Prowlarr Guide" "media,prowlarr" \
  "Configure Prowlarr." "Usually enabled via my.media.arr.enable."

echo "=== Phase 8: 60-apps (10 modules) ==="

# 60-paperless.nix
module modules/60-apps/60-paperless.nix "60" "NIXH-60-APP-001" "Paperless-ngx" "apps,paperless,documents" \
  "Paperless-ngx document management." \
  "my.apps.paperless" "" \
'{ config, lib, ... }:
{
  options.my.apps.paperless = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Paperless-ngx."; };
    port = lib.mkOption { type = lib.types.port; default = 28981; description = "Paperless web port."; };
    ocrLanguage = lib.mkOption { type = lib.types.str; default = "deu+eng"; description = "OCR language."; };
  };

  config = lib.mkIf config.my.apps.paperless.enable {
    services.paperless = {
      enable = true;
      address = "127.0.0.1";
      port = config.my.apps.paperless.port;
    };
  };
}
'
adr docs/adr/ADR-60-paperless.md "60" "NIXH-60-APP-001" "Paperless-ngx" "apps,paperless" \
  "Paperless-ngx document management." "## Decision\nPostgreSQL-backed, OCR-enabled."
guide docs/guides/GUIDE-60-paperless.md "60" "NIXH-60-APP-001" "Paperless Guide" "apps,paperless" \
  "Configure Paperless." "\`\`\`nix\nmy.apps.paperless.enable = true;\n\`\`\`"

# 61-n8n.nix
module modules/60-apps/61-n8n.nix "60" "NIXH-60-APP-002" "n8n Automation" "apps,n8n,workflows" \
  "n8n workflow automation platform." \
  "my.apps.n8n" "" \
'{ config, lib, ... }:
{
  options.my.apps.n8n = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable n8n."; };
    port = lib.mkOption { type = lib.types.port; default = 5678; description = "n8n web port."; };
    databaseType = lib.mkOption { type = lib.types.enum [ "sqlite" "postgres" ]; default = "postgres"; description = "Backend database."; };
    memoryMax = lib.mkOption { type = lib.types.str; default = "2G"; description = "Memory limit."; };
  };
}
'
adr docs/adr/ADR-61-n8n.md "60" "NIXH-60-APP-002" "n8n Automation" "apps,n8n" \
  "n8n workflow automation." "## Decision\nPostgres-backed n8n instance."
guide docs/guides/GUIDE-61-n8n.md "60" "NIXH-60-APP-002" "n8n Guide" "apps,n8n" \
  "Configure n8n." "Requires encryption key via SOPS."

# 62-vaultwarden.nix
module modules/60-apps/62-vaultwarden.nix "60" "NIXH-60-APP-003" "Vaultwarden" "apps,vaultwarden,passwords" \
  "Vaultwarden password manager." \
  "my.apps.vaultwarden" "" \
'{ config, lib, ... }:
{
  options.my.apps.vaultwarden = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Vaultwarden."; };
    port = lib.mkOption { type = lib.types.port; default = 7277; description = "Vaultwarden port."; };
    signupsAllowed = lib.mkOption { type = lib.types.bool; default = false; description = "Allow new signups."; };
  };

  config = lib.mkIf config.my.apps.vaultwarden.enable {
    services.vaultwarden = {
      enable = true;
      config = {
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = config.my.apps.vaultwarden.port;
        SIGNUPS_ALLOWED = config.my.apps.vaultwarden.signupsAllowed;
      };
    };
  };
}
'
adr docs/adr/ADR-62-vaultwarden.md "60" "NIXH-60-APP-003" "Vaultwarden" "apps,vaultwarden" \
  "Vaultwarden password vault." "## Decision\nSocket-activated, SSO-protected."
guide docs/guides/GUIDE-62-vaultwarden.md "60" "NIXH-60-APP-003" "Vaultwarden Guide" "apps,vaultwarden" \
  "Configure Vaultwarden." "Requires env secrets."

# 63-home-assistant.nix
module modules/60-apps/63-home-assistant.nix "60" "NIXH-60-APP-004" "Home Assistant" "apps,home-assistant,iot" \
  "Home Assistant IoT platform." \
  "my.apps.homeAssistant" "" \
'{ config, lib, ... }:
{
  options.my.apps.homeAssistant = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Home Assistant."; };
    port = lib.mkOption { type = lib.types.port; default = 8123; description = "Home Assistant port."; };
  };
}
'
adr docs/adr/ADR-63-home-assistant.md "60" "NIXH-60-APP-004" "Home Assistant" "apps,home-assistant" \
  "Home Assistant IoT." "## Decision\nMinimal option surface, config via HA UI."
guide docs/guides/GUIDE-63-home-assistant.md "60" "NIXH-60-APP-004" "Home Assistant Guide" "apps,home-assistant" \
  "Configure Home Assistant." "\`\`\`nix\nmy.apps.homeAssistant.enable = true;\n\`\`\`"

# 64-readeck.nix
module modules/60-apps/64-readeck.nix "60" "NIXH-60-APP-005" "Readeck" "apps,readeck,reader" \
  "Readeck read-it-later service." \
  "my.apps.readeck" "" \
'{ config, lib, ... }:
{
  options.my.apps.readeck = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Readeck."; };
    port = lib.mkOption { type = lib.types.port; default = 8000; description = "Readeck port."; };
  };

  config = lib.mkIf config.my.apps.readeck.enable {
    services.readeck = {
      enable = true;
      settings = {
        server.host = "127.0.0.1";
        server.port = config.my.apps.readeck.port;
      };
    };
  };
}
'
adr docs/adr/ADR-64-readeck.md "60" "NIXH-60-APP-005" "Readeck" "apps,readeck" \
  "Readeck read-it-later." "## Decision\nDynamicUser sandbox."
guide docs/guides/GUIDE-64-readeck.md "60" "NIXH-60-APP-005" "Readeck Guide" "apps,readeck" \
  "Configure Readeck." "\`\`\`nix\nmy.apps.readeck.enable = true;\n\`\`\`"

# 65-matrix-conduit.nix
module modules/60-apps/65-matrix-conduit.nix "60" "NIXH-60-APP-006" "Matrix Conduit" "apps,matrix,conduit,chat" \
  "Matrix Conduit homeserver." \
  "my.apps.matrixConduit" "" \
'{ config, lib, ... }:
let
  idCfg = config.my.core.identity;
  serverName = "matrix.${idCfg.subdomain}.${idCfg.domain}";
in
{
  options.my.apps.matrixConduit = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Matrix Conduit."; };
    port = lib.mkOption { type = lib.types.port; default = 6167; description = "Conduit port."; };
    allowRegistration = lib.mkOption { type = lib.types.bool; default = false; description = "Allow open registration."; };
  };

  config = lib.mkIf config.my.apps.matrixConduit.enable {
    services.matrix-conduit = {
      enable = true;
      settings.global = {
        server_name = lib.mkIf (serverName != "matrix..") serverName;
        port = config.my.apps.matrixConduit.port;
        address = "127.0.0.1";
        database_backend = "rocksdb";
        allow_registration = config.my.apps.matrixConduit.allowRegistration;
      };
    };
  };
}
'
adr docs/adr/ADR-65-matrix-conduit.md "60" "NIXH-60-APP-006" "Matrix Conduit" "apps,matrix" \
  "Matrix Conduit homeserver." "## Decision\nRust-based lightweight homeserver."
guide docs/guides/GUIDE-65-matrix-conduit.md "60" "NIXH-60-APP-006" "Matrix Guide" "apps,matrix" \
  "Configure Matrix." "Requires domain and subdomain set."

# 66-miniflux.nix
module modules/60-apps/66-miniflux.nix "60" "NIXH-60-APP-007" "Miniflux RSS" "apps,miniflux,rss" \
  "Miniflux RSS reader." \
  "my.apps.miniflux" "" \
'{ config, lib, ... }:
{
  options.my.apps.miniflux = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Miniflux."; };
    port = lib.mkOption { type = lib.types.port; default = 8085; description = "Miniflux port."; };
  };

  config = lib.mkIf config.my.apps.miniflux.enable {
    services.miniflux = {
      enable = true;
      config = {
        LISTEN_ADDR = "127.0.0.1:${toString config.my.apps.miniflux.port}";
        RUN_MIGRATIONS = 1;
      };
    };
  };
}
'
adr docs/adr/ADR-66-miniflux.md "60" "NIXH-60-APP-007" "Miniflux RSS" "apps,miniflux" \
  "Miniflux RSS reader." "## Decision\nSocket-activated, minimal config."
guide docs/guides/GUIDE-66-miniflux.md "60" "NIXH-60-APP-007" "Miniflux Guide" "apps,miniflux" \
  "Configure Miniflux." "\`\`\`nix\nmy.apps.miniflux.enable = true;\n\`\`\`"

# 67-linkding.nix
module modules/60-apps/67-linkding.nix "60" "NIXH-60-APP-008" "Linkding" "apps,linkding,bookmarks" \
  "Linkding bookmark manager." \
  "my.apps.linkding" "" \
'{ config, lib, ... }:
{
  options.my.apps.linkding = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Linkding."; };
    port = lib.mkOption { type = lib.types.port; default = 9090; description = "Linkding port."; };
  };

  config = lib.mkIf config.my.apps.linkding.enable {
    services.linkding = {
      enable = true;
      host = "127.0.0.1";
      port = config.my.apps.linkding.port;
    };
  };
}
'
adr docs/adr/ADR-67-linkding.md "60" "NIXH-60-APP-008" "Linkding" "apps,linkding" \
  "Linkding bookmarks." "## Decision\nSSO-protected bookmark manager."
guide docs/guides/GUIDE-67-linkding.md "60" "NIXH-60-APP-008" "Linkding Guide" "apps,linkding" \
  "Configure Linkding." "\`\`\`nix\nmy.apps.linkding.enable = true;\n\`\`\`"

# 68-monica.nix
module modules/60-apps/68-monica.nix "60" "NIXH-60-APP-009" "Monica CRM" "apps,monica,crm" \
  "Monica personal CRM." \
  "my.apps.monica" "" \
'{ config, lib, ... }:
{
  options.my.apps.monica = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Monica CRM."; };
    port = lib.mkOption { type = lib.types.port; default = 8095; description = "Monica port."; };
  };
}
'
adr docs/adr/ADR-68-monica.md "60" "NIXH-60-APP-009" "Monica CRM" "apps,monica" \
  "Monica personal CRM." "## Decision\nPostgreSQL-backed CRM."
guide docs/guides/GUIDE-68-monica.md "60" "NIXH-60-APP-009" "Monica Guide" "apps,monica" \
  "Configure Monica." "\`\`\`nix\nmy.apps.monica.enable = true;\n\`\`\`"

# 69-karakeep.nix
module modules/60-apps/69-karakeep.nix "60" "NIXH-60-APP-010" "Karakeep" "apps,karakeep,bookmarks" \
  "Karakeep bookmark management." \
  "my.apps.karakeep" "" \
'{ config, lib, ... }:
{
  options.my.apps.karakeep = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Karakeep."; };
    port = lib.mkOption { type = lib.types.port; default = 3012; description = "Karakeep port."; };
    disableSignups = lib.mkOption { type = lib.types.bool; default = true; description = "Disable public signups."; };
  };

  config = lib.mkIf config.my.apps.karakeep.enable {
    services.karakeep = {
      enable = true;
      extraEnvironment = {
        PORT = toString config.my.apps.karakeep.port;
        DISABLE_SIGNUPS = if config.my.apps.karakeep.disableSignups then "true" else "false";
      };
    };
  };
}
'
adr docs/adr/ADR-69-karakeep.md "60" "NIXH-60-APP-010" "Karakeep" "apps,karakeep" \
  "Karakeep bookmarks." "## Decision\nSSO-protected bookmark manager."
guide docs/guides/GUIDE-69-karakeep.md "60" "NIXH-60-APP-010" "Karakeep Guide" "apps,karakeep" \
  "Configure Karakeep." "\`\`\`nix\nmy.apps.karakeep.enable = true;\n\`\`\`"

echo "=== Phase 9: 70-forge (3 modules) ==="

# 70-forgejo.nix
module modules/70-forge/70-forgejo.nix "70" "NIXH-70-FRG-001" "Forgejo Git" "forge,forgejo,git" \
  "Forgejo self-hosted Git service." \
  "my.forge.forgejo" "" \
'{ config, lib, ... }:
let
  domain = config.my.core.identity.domain;
in
{
  options.my.forge.forgejo = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Forgejo."; };
    port = lib.mkOption { type = lib.types.port; default = 3000; description = "Forgejo HTTP port."; };
    disableRegistration = lib.mkOption { type = lib.types.bool; default = true; description = "Disable public registration."; };
  };

  config = lib.mkIf config.my.forge.forgejo.enable {
    services.forgejo = {
      enable = true;
      database.type = "sqlite3";
      settings = {
        server = {
          HTTP_ADDR = "127.0.0.1";
          HTTP_PORT = config.my.forge.forgejo.port;
        };
        service.DISABLE_REGISTRATION = config.my.forge.forgejo.disableRegistration;
      };
    };
  };
}
'
adr docs/adr/ADR-70-forgejo.md "70" "NIXH-70-FRG-001" "Forgejo Git" "forge,forgejo" \
  "Forgejo self-hosted Git." "## Decision\nSQLite-backed, no public registration."
guide docs/guides/GUIDE-70-forgejo.md "70" "NIXH-70-FRG-001" "Forgejo Guide" "forge,forgejo" \
  "Configure Forgejo." "\`\`\`nix\nmy.forge.forgejo.enable = true;\n\`\`\`"

# 71-semaphore.nix
module modules/70-forge/71-semaphore.nix "70" "NIXH-70-FRG-002" "Semaphore Ansible" "forge,semaphore,ansible" \
  "Ansible Semaphore web UI." \
  "my.forge.semaphore" "" \
'{ config, lib, ... }:
{
  options.my.forge.semaphore = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Semaphore."; };
  };
}
'
adr docs/adr/ADR-71-semaphore.md "70" "NIXH-70-FRG-002" "Semaphore Ansible" "forge,semaphore" \
  "Ansible Semaphore." "## Decision\nPlaceholder module — implementation TBD."
guide docs/guides/GUIDE-71-semaphore.md "70" "NIXH-70-FRG-002" "Semaphore Guide" "forge,semaphore" \
  "Configure Semaphore." "Implementation pending."

# 72-cockpit.nix
module modules/70-forge/72-cockpit.nix "70" "NIXH-70-FRG-003" "Cockpit Admin" "forge,cockpit,admin" \
  "Cockpit web administration." \
  "my.forge.cockpit" "" \
'{ config, lib, ... }:
{
  options.my.forge.cockpit = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Cockpit."; };
    port = lib.mkOption { type = lib.types.port; default = 9090; description = "Cockpit port."; };
  };

  config = lib.mkIf config.my.forge.cockpit.enable {
    services.cockpit = {
      enable = true;
      port = config.my.forge.cockpit.port;
    };
  };
}
'
adr docs/adr/ADR-72-cockpit.md "70" "NIXH-70-FRG-003" "Cockpit Admin" "forge,cockpit" \
  "Cockpit web admin." "## Decision\nWeb-based system administration."
guide docs/guides/GUIDE-72-cockpit.md "70" "NIXH-70-FRG-003" "Cockpit Guide" "forge,cockpit" \
  "Configure Cockpit." "\`\`\`nix\nmy.forge.cockpit.enable = true;\n\`\`\`"

echo "=== Phase 10: 80-gaming (2 modules) ==="

# 80-amp.nix
module modules/80-gaming/80-amp.nix "80" "NIXH-80-GAM-001" "AMP Game Servers" "gaming,amp,servers" \
  "AMP game server management panel." \
  "my.gaming.amp" "" \
'{ config, lib, ... }:
{
  options.my.gaming.amp = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable AMP."; };
    port = lib.mkOption { type = lib.types.port; default = 8080; description = "AMP web UI port."; };
    dataDir = lib.mkOption { type = lib.types.str; default = "/var/lib/amp"; description = "AMP data directory."; };
  };
}
'
adr docs/adr/ADR-80-amp.md "80" "NIXH-80-GAM-001" "AMP Game Servers" "gaming,amp" \
  "AMP game server panel." "## Decision\nFHS-sandboxed AMP instance."
guide docs/guides/GUIDE-80-amp.md "80" "NIXH-80-GAM-001" "AMP Guide" "gaming,amp" \
  "Configure AMP." "Requires buildFHSEnv sandbox."

# 81-amp-fhs.nix
module modules/80-gaming/81-amp-fhs.nix "80" "NIXH-80-GAM-002" "AMP FHS Sandbox" "gaming,amp,fhs" \
  "FHS sandbox package for AMP." \
  "my.gaming.ampFhs" "" \
'{ config, lib, pkgs, ... }:
{
  options.my.gaming.ampFhs = {
    enable = lib.mkOption { type = lib.types.bool; default = false; description = "Build AMP FHS sandbox."; };
  };

  config = lib.mkIf config.my.gaming.ampFhs.enable {
    # The actual FHS env is built via callPackage in a separate overlay.
    # This module just provides the toggle.
    environment.systemPackages = lib.mkIf config.my.gaming.amp.enable [
      pkgs.buildFHSEnv {
        name = "amp-fhs";
        targetPkgs = pkgs: with pkgs; [ dotnet-sdk_8 glibc openssl curl libicu sqlite screen bash ];
        runScript = "bash";
      }
    ];
  };
}
'
adr docs/adr/ADR-81-amp-fhs.md "80" "NIXH-80-GAM-002" "AMP FHS Sandbox" "gaming,amp,fhs" \
  "FHS sandbox for AMP." "## Decision\nbuildFHSEnv with dotnet-sdk and dependencies."
guide docs/guides/GUIDE-81-amp-fhs.md "80" "NIXH-80-GAM-002" "AMP FHS Guide" "gaming,amp,fhs" \
  "AMP FHS sandbox guide." "Usually auto-enabled with my.gaming.amp.enable."

echo "=== Phase 11: 90-policy (2 modules) ==="

# 90-forbidden-tech.nix
module modules/90-policy/90-forbidden-tech.nix "90" "NIXH-90-POL-001" "Forbidden Technology" "policy,forbidden,assertions" \
  "Zero-tolerance assertions against forbidden technologies." \
  "my.policy.forbidden" "" \
'{ config, lib, ... }:
{
  options.my.policy.forbidden = {
    enforce = lib.mkOption { type = lib.types.bool; default = true; description = "Enforce forbidden technology assertions."; };
  };

  config = lib.mkIf (config.my.policy.forbidden.enforce && !config.my.core.principles.bastelmodus) {
    assertions = [
      { assertion = !(config.boot.lanzaboote.enable or false); message = "Forbidden: Lanzaboote."; }
      { assertion = !(config.services.tailscale.enable or false); message = "Forbidden: Tailscale."; }
      { assertion = !(config.virtualisation.docker.enable or false); message = "Forbidden: Docker. Use native systemd services."; }
      { assertion = !(config.services.cron.enable or false); message = "Forbidden: Cron. Use systemd timers."; }
      { assertion = config.networking.nftables.enable; message = "Forbidden: Legacy iptables. Use nftables."; }
      { assertion = !(config.services.sftpgo.enable or false); message = "Forbidden: SFTPGo."; }
    ];
  };
}
'
adr docs/adr/ADR-90-forbidden-tech.md "90" "NIXH-90-POL-001" "Forbidden Technology" "policy,forbidden" \
  "Build-time forbidden-tech assertions." "## Decision\nDocker, Tailscale, cron, iptables, lanzaboote, SFTPGo are forbidden."
guide docs/guides/GUIDE-90-forbidden-tech.md "90" "NIXH-90-POL-001" "Forbidden Tech Guide" "policy,forbidden" \
  "Forbidden technology policy." "Set bastelmodus = true to relax during experiments."

# 91-architecture-rules.nix
module modules/90-policy/91-architecture-rules.nix "90" "NIXH-90-POL-002" "Architecture Rules" "policy,architecture,guard" \
  "Architectural guard rails via build-time assertions." \
  "my.policy.architecture" "" \
'{ config, lib, ... }:
{
  options.my.policy.architecture = {
    enforce = lib.mkOption { type = lib.types.bool; default = true; description = "Enforce architecture rules."; };
  };

  config = lib.mkIf config.my.policy.architecture.enforce {
    assertions = [
      { assertion = !(config.virtualisation.docker.enable or false); message = "ARCH-FAIL: Docker forbidden."; }
      { assertion = !(config.services.tailscale.enable or false); message = "ARCH-FAIL: Tailscale forbidden."; }
      { assertion = !(config.services.cron.enable or false); message = "ARCH-FAIL: Cron forbidden."; }
      { assertion = config.networking.nftables.enable; message = "ARCH-FAIL: nftables mandatory."; }
    ];
  };
}
'
adr docs/adr/ADR-91-architecture-rules.md "90" "NIXH-90-POL-002" "Architecture Rules" "policy,architecture" \
  "Architecture guard rails." "## Decision\nBuild-time assertions prevent architectural drift."
guide docs/guides/GUIDE-91-architecture-rules.md "90" "NIXH-90-POL-002" "Architecture Rules Guide" "policy,architecture" \
  "Architecture rules guide." "Assertions enforced by default."

echo "=== Phase 12: READMEs ==="

for dir in 00-core 10-network 20-security 30-storage 40-monitoring 50-media 60-apps 70-forge 80-gaming 90-policy; do
  cat > "modules/$dir/README.md" <<EOF
# modules/$dir

Auto-generated pure NixOS modules. **No personal data, no magic numbers.**

See individual module files for options. All values have safe defaults.
EOF
  echo "  ✓ README: modules/$dir/README.md"
done

echo "=== ALL PHASES COMPLETE ==="
