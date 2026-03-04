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
  imports =
    (lib.optional (builtins.elem "dwm" desktops) ./dwm-setup.nix)
    ++ (lib.optional (builtins.elem "niri" desktops) ./niri-setup.nix);
}
