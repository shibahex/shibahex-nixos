{
  pkgs,
  host,
  lib,
  ...
}:
let
  variables = import ../../hosts/${host}/variables.nix { pkgs = pkgs; };
  desktops = variables.desktops or [ "dwm" ];
in
{
  # Dark theme
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

  imports =
    (lib.optional (builtins.elem "dwm" desktops) ./dwm-setup.nix)
    ++ (lib.optional (builtins.elem "niri" desktops) ./niri-setup.nix);
}
