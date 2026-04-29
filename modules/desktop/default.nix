{ pkgs
, host
, lib
, self
, ...
}:
let
  variables = import "${self}/hosts/${host}/variables.nix" { inherit pkgs; };
  desktops = variables.desktops or [ "dwm" ];
in
{
  # Dark theme
  stylix.enable = true;
  stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/default-dark.yaml";

  imports =
    (lib.optional (builtins.elem "dwm" desktops) ./dwm/dwm-setup.nix)
    ++ (lib.optional (builtins.elem "niri" desktops) ./niri/niri-setup.nix);

  services.displayManager.ly.enable = true;

}
