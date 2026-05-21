{lib, ...}: let
  nms = {
    id = "NIXH-00-COR-018";
    title = "Global Service Helpers";
    description = "Central library providing the mkService abstraction.";
    layer = 00;
    nixpkgs.category = "tools/admin";
    capabilities = ["architecture/abstraction" "system/hardening"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 3;
  };
in {
  options.my.meta.lib_helpers = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
  };
}
