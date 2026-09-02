{ pkgs, inputs, ... }:
{
  imports = [ inputs.reaper-flake.homeManagerModules.default ];

  programs.reaper = {
    enable = true;
    theme = {
      active = "Reapertips Theme.ReaperThemeZip";
      packages = [ inputs.reaper-flake.packages.${pkgs.system}.reapertips-theme ];
    };
    swell.colortheme = {
      enable = true;
      preset = "stylix";
    };
    extensions = {
      reapack.enable = true;
      sws.enable = true;
    };
  };
}
