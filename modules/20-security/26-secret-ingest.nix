# ---NIXMETA
# ---
# domain: 20
# id: "NIXH-20-SEC-011"
# title: "Secret Ingest"
# type: module
# status: draft
# complexity: 2
# reviewed: 2026-05-21
# tags: [security,secrets,sops,automation,ingest]
# description: "Directory watcher for secret landing zone — auto-processes dropped secrets via SOPS."
# path: "modules/20-security/26-secret-ingest.nix"
# provides: [my.security.secretIngest]
# requires: [my.core.secrets]
# links:
#   adr: docs/adr/ADR-20-security.md
#   guide: docs/guides/20-security.md
#   module: modules/20-security/26-secret-ingest.nix
# ---
# ---ENDNIXMETA

# ─── KB Nuggets ───
# ### Kontext
#
# Secrets müssen sicher und versioniert ins System gelangen. Statt manuell
# SOPS zu bedienen, wird ein Landing-Zone-Verzeichnis überwacht. Sobald eine
# Datei dort abgelegt wird, wird sie automatisch verarbeitet.
#
# ### Entscheidung
#
# **Secret Ingest Pattern:**
# 1.  **systemd.path Watcher** — Überwacht Verzeichnis auf neue Dateien.
# 2.  **One-Shot Service** — Wird bei Datei-Erkennung ausgelöst.
# 3.  **Python Processor** — Kann komplexe Validierung/Transformation.
# 4.  **SOPS Integration** — Verarbeitet nur SOPS-verschlüsselte Dateien.
#
# ### SRE-Standards
#
# - Landing-Zone: /etc/nixos/secret-landing-zone (Root-only).
# - Watcher ist MakeDirectory = true (erstellt Verzeichnis falls nötig).
# - Service ist Type = oneshot (läuft einmal pro Trigger).
# ─── End KB Nuggets ───

{ config, lib, pkgs, ... }:

let
  landingZone = "/etc/nixos/secret-landing-zone";
  python = pkgs.python3;

  ingestScript = pkgs.writeScript "ingest-run" ''
    #!${python}/bin/python
    import os
    import sys
    import glob
    import subprocess
    from pathlib import Path

    LANDING_ZONE = "${landingZone}"

    def process_secrets():
        """Process all files in the secret landing zone."""
        files = glob.glob(os.path.join(LANDING_ZONE, "*"))
        if not files:
            return

        for filepath in files:
            fname = os.path.basename(filepath)
            print(f"Processing: {fname}")
            try:
                # Decrypt with SOPS and move to secrets directory
                result = subprocess.run(
                    ["${pkgs.sops}/bin/sops", "-d", filepath],
                    capture_output=True, text=True
                )
                if result.returncode == 0:
                    print(f"  ✅ Decrypted {fname}")
                    # Move to processed
                    processed = os.path.join(LANDING_ZONE, ".processed", fname)
                    os.makedirs(os.path.dirname(processed), exist_ok=True)
                    os.rename(filepath, processed)
                else:
                    print(f"  ❌ Failed to decrypt {fname}: {result.stderr}")
            except Exception as e:
                print(f"  ❌ Error processing {fname}: {e}")

    if __name__ == "__main__":
        process_secrets()
  '';
in
{
  options.my.security.secretIngest = {
    enable = lib.mkEnableOption "Secret landing zone watcher and ingest processor";
    landingZone = lib.mkOption {
      type = lib.types.str;
      default = landingZone;
      description = "Path to the secret landing zone directory.";
    };
  };

  config = lib.mkIf config.my.security.secretIngest.enable {
    # ── Directory Watcher ──
    systemd.paths.secret-ingest = {
      description = "Watcher for Secret Landing Zone";
      wantedBy = [ "multi-user.target" ];
      pathConfig = {
        DirectoryNotEmpty = config.my.security.secretIngest.landingZone;
        MakeDirectory = true;
      };
    };

    # ── Ingest Service ──
    systemd.services.secret-ingest = {
      description = "Secret Ingest Agent";
      path = with pkgs; [ sops coreutils ];
      serviceConfig = {
        Type = "oneshot";
        ExecStart = ingestScript;
        User = "root";
      };
    };

    # ── Landing Zone Directory ──
    systemd.tmpfiles.rules = [
      "d ${config.my.security.secretIngest.landingZone} 0700 root root -"
      "d ${config.my.security.secretIngest.landingZone}/.processed 0700 root root -"
    ];
  };
}
