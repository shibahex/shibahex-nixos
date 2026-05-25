{ pkgs, xboxTheme, ... }:
let
  pegasus = import ./services/pegasus-frontend.nix { inherit pkgs; };
in
{
  home.file.".config/pegasus-frontend/themes/XboxOSv2".source = pegasus.xboxTheme;
}
