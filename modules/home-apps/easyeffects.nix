# The goal of this module is to add easyeffects presets from git into the .config file
{ pkgs, ... }:
let
  easyEffectsProfiles = pkgs.fetchFromGitHub {
    "owner" = "shibahex";
    "repo" = "easyeffects-presets";
    "rev" = "2c9ef3703fa14805e58cf9ecf75bbdba66154cba";
    "hash" = "sha256-GJBLcIlzOz10Zn1qW/slALGLBaMTOkdKixWzf8PUVQA=";
  };
in
{
  home.file.".local/share/easyeffects" = {
    source = easyEffectsProfiles;
    recursive = true;
  };
}

