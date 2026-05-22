# ---NIXMETA
# ---
# domain: 70
# id: "NIXH-70-FORGE-035"
# title: "Jailed Agents — LLM Sandbox"
# type: module
# status: draft
# complexity: 3
# reviewed: 2026-05-22
# tags: [forge,llm,sandbox,bubblewrap,jail,security,agents]
# description: "Secure bubblewrap sandbox for LLM coding agents (jailed-agents pattern). Zero-trust isolation with declarative directory access, package control, and network confinement."
# path: "modules/70-forge/35-jailed-agents.nix"
# provides: [my.forge.jailed-agents]
# requires: [00-core]
# links:
#   adr: docs/adr/ADR-70-forge.md
#   guide: docs/guides/70-forge.md
#   module: modules/70-forge/35-jailed-agents.nix
#   upstream: https://github.com/andersonjoseph/jailed-agents
# sources: [andersonjoseph/jailed-agents, alexdavid/jail.nix, numtide/llm-agents.nix]
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# LLM-Agenten (Open WebUI, coding agents) brauchen Zugriff auf System-Tools,
# aber nicht auf SSH-Keys, /etc, oder andere sensitive Daten.
# jailed-agents (59⭐) nutzt bubblewrap + jail.nix für Zero-Trust-Sandboxing.
# ### Entscheidung
#
# Wir implementieren das jailed-agents Pattern als NixOS-Modul:
# 1. bubblewrap als Basis — leichtgewichtig, Flatpak-proven
# 2. Deklarative Directory-Zugriffe (readwrite/readonly)
# 3. Package-Whitelist — Agent bekommt nur was er braucht
# 4. Netzwerk-Zugriff optional kontrollierbar
# 5. Pre-configured Agents: opencode, claude-code, crush, gemini-cli
# 6. Custom Agent Builder über makeJailedAgent
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  cfg = config.my.forge.jailed-agents;

  # ── Common Packages (jailed-agents defaults) ──
  commonPkgs = with pkgs; [
    bashInteractive
    coreutils
    curl
    wget
    jq
    git
    which
    ripgrep
    gnugrep
    gawk
    procps
    findutils
    gzip
    unzip
    gnutar
    diffutils
  ];

  # ── Bubblewrap Jail Builder ──
  makeJail = {
    name,
    agentPkg,
    extraPkgs ? [],
    readwriteDirs ? [],
    readonlyDirs ? [],
    allowNetwork ? true,
    extraArgs ? [],
  }:
    let
      # bubblewrap argument builder
      bwArgs = lib.flatten [
        # ── Base Isolation ──
        "--unshare-all"
        "--die-with-parent"
        "--new-session"
        "--clearenv"

        # ── Filesystem: Minimal Read-Only Bind Mounts ──
        "--ro-bind ${pkgs.bash}/bin/bash /bin/bash"
        "--ro-bind ${pkgs.coreutils}/bin /usr/bin/coreutils"
        "--symlink /usr/bin/coreutils/env /usr/bin/env"
        "--symlink /usr/bin/coreutils/ls /usr/bin/ls"
        "--symlink /usr/bin/coreutils/cat /usr/bin/cat"

        # ── Agent Package ──
        "--ro-bind ${agentPkg}/bin /usr/bin/agent"
        "--symlink /usr/bin/agent/${lib.strings.head (lib.strings.splitString " " (lib.strings.head (lib.strings.splitString "\n" (lib.getExe agentPkg))))} /usr/bin/${name}"

        # ── Proc/Dev ──
        "--proc /proc"
        "--dev /dev"
        "--tmpfs /tmp"
        "--tmpfs /var"
        "--tmpfs /run"

        # ── Home Directory: Isolated ──
        "--dir /home/agent"
        "--setenv HOME /home/agent"

        # ── Network (optional) ──
        (lib.optional allowNetwork "--share-net")

        # ── Read-Write Directories (agent config/state) ──
        (map (d: "--bind ${d} ${d}") readwriteDirs)

        # ── Read-Only Directories (system libs, etc.) ──
        (map (d: "--ro-bind ${d} ${d}") readonlyDirs)

        # ── Extra Args ──
        extraArgs

        # ── Environment ──
        "--setenv PATH /usr/bin:/bin"
        "--setenv USER agent"
        "--setenv LOGNAME agent"

        # ── Working Directory ──
        "--chdir /home/agent"

        # ── UID/GID ──
        "--uid 1000"
        "--gid 1000"
      ];

      # Wrapper script
      jailScript = pkgs.writeShellScriptBin name ''
        exec ${pkgs.bubblewrap}/bin/bwrap \
          ${lib.concatStringsSep " \\\n          " bwArgs} \
          /usr/bin/${name} "$@"
      '';
    in
      jailScript;

  # ── Pre-configured Agent Builders ──
  makeJailedOpencode = {
    extraPkgs ? [],
    readwriteDirs ? [],
    allowNetwork ? true,
  }: makeJail {
    name = "jailed-opencode";
    agentPkg = pkgs.opencode;
    extraPkgs = extraPkgs;
    readwriteDirs = readwriteDirs ++ [
      "/home/agent/.config/opencode"
      "/home/agent/.local/share/opencode"
      "/home/agent/.local/state/opencode"
    ];
    inherit allowNetwork;
  };

  makeJailedClaudeCode = {
    extraPkgs ? [],
    readwriteDirs ? [],
    allowNetwork ? true,
  }: makeJail {
    name = "jailed-claude-code";
    agentPkg = pkgs.claude-code;
    extraPkgs = extraPkgs;
    readwriteDirs = readwriteDirs ++ [
      "/home/agent/.config/claude-code"
      "/home/agent/.local/share/claude-code"
    ];
    inherit allowNetwork;
  };

  makeJailedCrush = {
    extraPkgs ? [],
    readwriteDirs ? [],
    allowNetwork ? true,
  }: makeJail {
    name = "jailed-crush";
    agentPkg = pkgs.crush;
    extraPkgs = extraPkgs;
    readwriteDirs = readwriteDirs ++ [
      "/home/agent/.config/crush"
      "/home/agent/.local/share/crush"
    ];
    inherit allowNetwork;
  };

  # ── Custom Agent Builder ──
  makeJailedAgent = {
    name,
    package,
    configPaths ? [],
    extraPkgs ? [],
    readwriteDirs ? [],
    readonlyDirs ? [],
    allowNetwork ? true,
  }: makeJail {
    inherit name allowNetwork;
    agentPkg = package;
    extraPkgs = extraPkgs;
    readwriteDirs = readwriteDirs ++ configPaths;
    inherit readonlyDirs;
  };

in
{
  options.my.forge.jailed-agents = {
    enable = lib.mkEnableOption "LLM agent sandboxing via bubblewrap (jailed-agents pattern)";

    # ── Global Settings ──
    defaultNetwork = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Allow network access for jailed agents by default.";
    };

    # ── Project Workspaces (read-write access for agents) ──
    workspaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = [ "/srv/projects/myproject" "/home/user/code" ];
      description = "Project directories that jailed agents can read and write.";
    };

    # ── Read-Only System Access ──
    readonlyPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "/nix/store" ];
      description = "System paths that jailed agents can read but not modify.";
    };

    # ── Extra Packages Available in Jail ──
    extraPackages = lib.mkOption {
      type = lib.types.listOf lib.types.package;
      default = [];
      example = [ pkgs.nodejs pkgs.python3 pkgs.go ];
      description = "Additional packages available inside the jail.";
    };

    # ── Pre-configured Agents ──
    agents = {
      opencode = {
        enable = lib.mkEnableOption "Jailed OpenCode agent";
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Extra packages for jailed opencode.";
        };
        workspaces = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Workspace directories for jailed opencode.";
        };
        allowNetwork = lib.mkOption {
          type = lib.types.bool;
          default = cfg.defaultNetwork;
          description = "Allow network access for jailed opencode.";
        };
      };
      claude-code = {
        enable = lib.mkEnableOption "Jailed Claude Code agent";
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Extra packages for jailed claude-code.";
        };
        workspaces = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Workspace directories for jailed claude-code.";
        };
        allowNetwork = lib.mkOption {
          type = lib.types.bool;
          default = cfg.defaultNetwork;
          description = "Allow network access for jailed claude-code.";
        };
      };
      crush = {
        enable = lib.mkEnableOption "Jailed Crush agent";
        extraPackages = lib.mkOption {
          type = lib.types.listOf lib.types.package;
          default = [];
          description = "Extra packages for jailed crush.";
        };
        workspaces = lib.mkOption {
          type = lib.types.listOf lib.types.str;
          default = [];
          description = "Workspace directories for jailed crush.";
        };
        allowNetwork = lib.mkOption {
          type = lib.types.bool;
          default = cfg.defaultNetwork;
          description = "Allow network access for jailed crush.";
        };
      };
    };

    # ── Exposed Library Functions ──
    lib = {
      makeJailedOpencode = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = makeJailedOpencode;
        visible = false;
        description = "Create a jailed OpenCode agent.";
      };
      makeJailedClaudeCode = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = makeJailedClaudeCode;
        visible = false;
        description = "Create a jailed Claude Code agent.";
      };
      makeJailedCrush = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = makeJailedCrush;
        visible = false;
        description = "Create a jailed Crush agent.";
      };
      makeJailedAgent = lib.mkOption {
        type = lib.types.functionTo lib.types.package;
        default = makeJailedAgent;
        visible = false;
        description = "Create a custom jailed agent.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    # ── bubblewrap Package ──
    environment.systemPackages = [
      pkgs.bubblewrap
    ];

    # ── Kernel: Unprivileged User Namespaces ──
    # Required for bubblewrap without root
    security.unprivilegedUsernsClone = true;

    # ── Expose Library Functions via Config ──
    my.forge.jailed-agents.lib = {
      inherit makeJailedOpencode makeJailedClaudeCode makeJailedCrush makeJailedAgent;
    };

    # ── Pre-configured Agent Scripts ──
    environment.systemPackages = lib.mkMerge [
      (lib.mkIf cfg.agents.opencode.enable [
        (makeJailedOpencode {
          extraPkgs = cfg.agents.opencode.extraPackages ++ cfg.extraPackages ++ commonPkgs;
          readwriteDirs = cfg.agents.opencode.workspaces ++ cfg.workspaces;
          allowNetwork = cfg.agents.opencode.allowNetwork;
        })
      ])
      (lib.mkIf cfg.agents.claude-code.enable [
        (makeJailedClaudeCode {
          extraPkgs = cfg.agents.claude-code.extraPackages ++ cfg.extraPackages ++ commonPkgs;
          readwriteDirs = cfg.agents.claude-code.workspaces ++ cfg.workspaces;
          allowNetwork = cfg.agents.claude-code.allowNetwork;
        })
      ])
      (lib.mkIf cfg.agents.crush.enable [
        (makeJailedCrush {
          extraPkgs = cfg.agents.crush.extraPackages ++ cfg.extraPackages ++ commonPkgs;
          readwriteDirs = cfg.agents.crush.workspaces ++ cfg.workspaces;
          allowNetwork = cfg.agents.crush.allowNetwork;
        })
      ])
    ];
  };
}
