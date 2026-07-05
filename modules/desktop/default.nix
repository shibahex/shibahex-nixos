# modules/desktop/default.nix
{ pkgs
, host
, lib
, self
, ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { inherit pkgs; };
  desktops = variables.desktops or [ "dwm" ];
  hasBigscreen = builtins.elem "bigscreen" desktops;
in
{
  # Dark theme
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

  imports =
    (lib.optional (builtins.elem "dwm" desktops) ./dwm/dwm-setup.nix)
    ++ (lib.optional (builtins.elem "niri" desktops) ./niri/niri-setup.nix)
    ++ (lib.optional hasBigscreen ./plasma/plasma-bigscreen.nix);

  # Turn on your custom module if bigscreen is in variables.nix
  ft.plasmaBigscreen.enable = hasBigscreen;

  # Only use Ly if Bigscreen (which uses SDDM) is not active
  services.displayManager.ly.enable = !hasBigscreen;
}
