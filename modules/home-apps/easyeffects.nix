# The goal of this module is to add easyeffects presets from git into the .config file
{ pkgs, ... }:
let
  easyEffectsProfiles = pkgs.fetchFromGitHub
{
    "owner": "shibahex",
    "repo": "easyeffects-presets",
    "rev": "4881e625b4debbfc9fc007f05c10184e0bfff3ee",
    "hash": "sha256-cWQBVPbB+/VrYjid+qJ+yord6gxfJ7DGZCoPpaBuQXY="
};
in
{
  home.file.".config/easyeffects" = {
    source = easyEffectsProfiles;
    recursive = true;
  };
}
