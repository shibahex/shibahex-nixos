{
  pkgs,
  host,
  lib,
  self,
  ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { inherit pkgs; };
  desktops = variables.desktops or [ "dwm" ];
  hasDesktop = d: builtins.elem d desktops;
in
{
  imports =
    (lib.optional (hasDesktop "dwm") ./dwm/dwm-setup.nix)
    ++ (lib.optional (hasDesktop "niri") ./niri/niri-setup.nix)
    ++ (lib.optional (hasDesktop "oxwm") ./oxwm/oxwm-setup.nix)
    ++ (lib.optional (hasDesktop "hyprland") ./hyprland/hyprland-setup.nix)
    ++ [ ./plasma/plasma-bigscreen.nix ];

  stylix.enable = lib.mkDefault true;
  stylix.base16Scheme = lib.mkDefault "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

  plasmaBigscreen.enable = lib.mkDefault (hasDesktop "bigscreen");
  services.displayManager.ly.enable = lib.mkDefault true;
}
