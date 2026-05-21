{ lib, ... }:
let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-026";
    title = "Principles";
    description = "Core architectural principles and the manifesto of the NixHome project.";
    layer = 00;
    nixpkgs.category = "documentation/architecture";
    capabilities = [ "architecture/manifesto" "system/standards" ];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 1;
  };
in
{
  options.my.meta.principles = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for principles module";
  };

  config = {
    # Rein dokumentatives Modul.
  };
}
