{
  config,
  lib,
  pkgs,
  ...
}: let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-031";
    title = "SSH Rescue";
    description = "Temporary 5-minute SSH window with password auth for emergency recovery.";
    layer = 00;
    nixpkgs.category = "system/networking";
    capabilities = ["security/recovery" "ssh/password-fallback"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  user = config.my.configs.identity.user;
  recoveryWindowSeconds = 300;

  recoveryStatus = pkgs.writeShellScriptBin "ssh-recovery-status" ''
    #!/usr/bin/env bash
    if systemctl is-active --quiet ssh-recovery-window; then
      echo -e "\033[1;33m⏱  SSH Recovery Window: AKTIV\033[0m"
      exit 0
    fi
    echo -e "\033[0;32m🔒 SSH Recovery Window: INAKTIV\033[0m"
    exit 1
  '';
in {
  options.my.meta.ssh_rescue = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for ssh-rescue module";
  };

  config = lib.mkIf config.my.services.sshRescue.enable {
    systemd.services.ssh-recovery-window = {
      description = "SSH Password Recovery Window (5min after boot)";
      wantedBy = ["multi-user.target"];
      after = ["sshd.service" "network-online.target"];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      script = ''
        cp /etc/ssh/sshd_config /tmp/sshd_config.backup
        sed -i 's/^PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
        systemctl reload sshd
        sleep ${toString recoveryWindowSeconds}
        mv /tmp/sshd_config.backup /etc/ssh/sshd_config
        systemctl reload sshd
      '';
    };

    environment.systemPackages = [recoveryStatus];
    programs.bash.shellAliases = {
      ssh-recovery-status = "${recoveryStatus}/bin/ssh-recovery-status";
      ssh-recovery-enable = "sudo systemctl start ssh-recovery-manual";
    };
  };
}
