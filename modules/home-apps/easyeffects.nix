# The goal of this module is to add easyeffects presets from git into the .config file
{ pkgs, ... }:
let
  easyEffectsProfiles = pkgs.fetchFromGitHub {
    "owner" = "shibahex";
    "repo" = "easyeffects-presets";
    "rev" = "5dc176fd3061882d58d8c1768f49197a11906973";
    "hash" = "sha256-2GybT4WcXxiGSakQrE9mhn3Lwj1AH37Fh9F3YZMViPM=";
  };
in
{
  home.file.".local/share/easyeffects" = {
    source = easyEffectsProfiles;
    recursive = true;
  };
}

