# The goal of this module is to add easyeffects presets from git into the .config file
{ pkgs, ... }:
let
  easyEffectsProfiles = pkgs.fetchFromGitHub {
    "owner" = "shibahex";
    "repo" = "easyeffects-presets";
    "rev" = "87fe1b742379618272c8934b6962cefcb2a9ed25";
    "hash" = "sha256-WDk73L/6mpc1EW5hZv1hV964IitE85wZcFBdD7uWL7w=";
  };
in
{
  home.file.".local/share/easyeffects" = {
    source = easyEffectsProfiles;
    recursive = true;
  };
}

