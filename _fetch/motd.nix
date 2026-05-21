{ config, pkgs, lib, ... }:
let
  nms = {
    id = "NIXH-00-COR-022";
    title = "MOTD & Shell UI";
    description = "Dynamic login dashboard and interactive shell initialization.";
    layer = 00;
    nixpkgs.category = "system/settings";
    capabilities = [ "shell/ui" "system/status-reminders" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
  domain = config.my.configs.identity.domain;
  host = config.my.configs.identity.host;
  firewallReminder = if config.networking.firewall.enable then "Firewall: ACTIVE" else "WARNING: Firewall is DISABLED.";
in
{
  options.my.meta.motd = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata";
  };

  config = {
    environment.etc."motd".text = ''
      ${host}.${domain} (NMS v2.3 SRE Edition)
      ${firewallReminder}
      Standard Port: ${toString config.my.ports.ssh}
      Local Proxy: Caddy (Edge)
    '';
    programs.bash.interactiveShellInit = ''
      if [[ $- == *i* ]] && [[ -t 1 ]]; then
        IP=$(hostname -I | awk '{print $1}')
        echo -e "\e[1;32mWelcome back, ${config.my.configs.identity.user}!\e[0m"
        echo -e "\e[1;34mSystem IP:\e[0m $IP"
        if timeout 0.2 systemctl is-active --quiet sshd-recovery.service 2>/dev/null; then
           echo -e "\e[1;31m🚨 RECOVERY WINDOW ACTIVE (Port 2222)\e[0m"
        fi
      fi
    '';
  };
}
