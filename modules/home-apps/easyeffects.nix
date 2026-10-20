# The goal of this module is to add easyeffects presets from git into the .config file
{ pkgs, ... }:
let
  easyEffectsProfiles = pkgs.fetchFromGitHub {
    "owner" = "shibahex";
    "repo" = "easyeffects-presets";
    "rev" = "5647521a7d874eabd08948b4f442027ffeec1b3a";
    "hash" = "sha256-QZc1v71cn++FBa0m46aqM91cdtbdUN7Vj5pMHj1VXqc=";
  };
in
{
  home.file.".local/share/easyeffects" = {
    source = easyEffectsProfiles;
    recursive = true;
  };
}
