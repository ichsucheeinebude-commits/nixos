{
  config,
  lib,
  ...
}: let
  # 🚀 NMS v4.0 Metadaten
  nms = {
    id = "NIXH-00-COR-039";
    title = "Users (Declarative Only)";
    description = "Strict declarative user and group management, ensuring no imperative mutations.";
    layer = 00;
    nixpkgs.category = "system/security";
    capabilities = ["system/users" "security/no-mutable-users"];
    audit.last_reviewed = "2026-03-02";
    audit.complexity = 2;
  };

  user = config.my.configs.identity.user;
in {
  options.my.meta.users = lib.mkOption {
    type = lib.types.attrs;
    default = nms;
    readOnly = true;
    description = "NMS metadata for users module";
  };

  config = {
    users.users.${user} = {
      isNormalUser = true;
      extraGroups = ["wheel" "video" "render" "media"];
      openssh.authorizedKeys.keys = ["ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJRDbyFjT4SEL8yxNwZuEBPORD82qlJJhdr2r4qz1vCX"];
    };
    users.groups.media = {gid = 169;};
    users.mutableUsers = false;
  };
}
