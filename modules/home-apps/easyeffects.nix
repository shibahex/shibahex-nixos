# The goal of this module is to add easyeffects presets from git into the .config file
{ pkgs, ... }:
let
  easyEffectsProfiles = pkgs.fetchFromGitHub {
    "owner" = "shibahex";
    "repo" = "easyeffects-presets";
    "rev" = "45d9a8cebcbe090c9ddba6a4f15d3f17ed22109e";
    "hash" = "sha256-MNy7P+VIey4dRg05MJnR5MZhTB5AkL3kPHHdJnSsBRw=";
  };
in
{
  home.file.".config/easyeffects" = {
    source = easyEffectsProfiles;
    recursive = true;
  };
}
