# ---NIXMETA
# {
#   "specVersion": "2.0",
#   "id": "NIXH-000-COR-PRN-001",
#   "title": "NixHome Architectural Principles",
#   "layer": 0,
#   "category": "core/documentation",
#   "lastReviewed": "2026-05-19",
#   "reviewedBy": "Gemini",
#   "status": "production",
#   "complexity": 1,
#   "tags": ["principles", "architecture", "manifesto"],
#   "description": "Core manifesto and architectural principles of the NixHome project."
# }
# ---ENDNIXMETA

{ lib, ... }:
let
 # 🚀 NMS v4.2 Metadaten (hardened Manifesto)
 nms = {
 id = "NIXH-00-COR-026";
 title = "Architectural Principles";
 description = "The core manifesto of the NixHome project. Defines SRE standards and isomorphism.";
 layer = 00;
 nixpkgs.category = "documentation/architecture";
 capabilities = [ "architecture/manifesto" "system/standards" "sre/best-practices" ];
 audit.last_reviewed = "2026-04-27";
 audit.complexity = 1;
 source_repo = "grapefruit89/mynixos";
 };
in
{
 options.my.meta.principles = lib.mkOption {
 type = lib.types.attrs;
 default = nms;
 readOnly = true;
 };

 config = {
 # 📜 THE NIXHOME MANIFESTO (v4.2)
 # ---------------------------------------------------------
 # 1. ISOMORPHISM: The repository structure IS the system structure.
 # 2. STATELESS CORE: Root (/) is on tmpfs. State is an artifact.
 # 3. SOURCE-SINK TRACEABILITY: Every config value has a clear origin.
 # 4. hardened HARDENING: Security is not a feature, it's the foundation.
 # 5. ZERO-TOUCH RECOVERY: Hardware is a vessel, Identity is on the USB anchor.
 # ---------------------------------------------------------

 # Warning: Ensure no illegal cross-layer dependencies
 warnings = [
 # Placeholder for future logic check
 ];
 };
}
