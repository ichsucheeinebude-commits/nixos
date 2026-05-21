{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.2 Metadaten
  nms = {
    id = "NIXH-00-COR-007";
    title = "Config Merger";
    description = "Dynamic bridge between NixOS declarations and user-managed JSON overrides for runtime services.";
    layer = 00;
    nixpkgs.category = "tools/admin";
    capabilities = ["config/merger" "system/runtime-config"];
    audit.last_reviewed = "2026-03-03";
    audit.complexity = 2;
  };

  runDir = "/run/nixhome";
  userConfig = "/var/lib/nixhome/user-config.json";
  finalConfig = "${runDir}/config.json";

  nixDefaults = pkgs.writeText "nix-defaults.json" (builtins.toJSON {
    domain = config.my.configs.identity.domain;
    email = config.my.configs.identity.email;
    lanIP = config.my.configs.server.lanIP;
    hostName = config.my.configs.identity.host;
    bastelmodus = config.my.configs.bastelmodus;
  });

  mergerScript = pkgs.writeShellScript "nixhome-config-merger" ''
    set -euo pipefail
    mkdir -p ${runDir}
    if [ ! -f "${userConfig}" ]; then
      echo "{}" > "${userConfig}"
      chown root:root "${userConfig}"
      chmod 644 "${userConfig}"
    fi
    ${pkgs.jq}/bin/jq -s '.[0] * .[1]' "${nixDefaults}" "${userConfig}" > "${finalConfig}.tmp"
    mv "${finalConfig}.tmp" "${finalConfig}"
    chmod 644 "${finalConfig}"
  '';

  applyScript = pkgs.writeShellScriptBin "nixhome-apply" ''
    set -euo pipefail
    echo "🔄 Merging configuration..."
    systemctl start nixhome-config-merger.service
    echo "🚀 Reloading services..."
    if systemctl is-active caddy >/dev/null 2>&1; then systemctl reload caddy; fi
    if systemctl is-active pocket-id >/dev/null 2>&1; then systemctl restart pocket-id; fi
    echo "✨ Fertig!"
  '';
in {
  options.my.meta.config_merger = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for config-merger module";
  };

  config = lib.mkIf config.my.services.configMerger.enable {
    systemd.services.nixhome-config-merger = {
      description = "Merge Nix Defaults with User JSON Config";
      before = ["caddy.service" "pocket-id.service" "landing-zone-ui.service"];
      wantedBy = ["multi-user.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        ExecStart = mergerScript;
      };
    };
    environment.systemPackages = [applyScript pkgs.jq];
    systemd.tmpfiles.rules = ["d /var/lib/nixhome 0755 root root -"];
  };
}
/**
* ---
 * technical_integrity:
 *   checksum: sha256:2ee5174563c033b9f3e6474579e8054289d9f927cb7823461d65f29c690ba98b
 *   eof_marker: NIXHOME_VALID_EOF* ---
*/

