{ pkgs, ... }:
let
  xboxTheme = pkgs.fetchFromGitHub {
    owner = "luxureousproductions-bit";
    repo = "XboxOSv2";
    rev = "master";
    hash = "sha256-C3sCpqNFlhof8fZXv77YyGRmOFK06pJ4SJowx2lHg6k=";
  };
  gameOSTheme = pkgs.fetchFromGitHub {
    owner = "PlayingKarrde";
    repo = "gameOS";
    rev = "master";
    hash = "sha256-EBpIe0aw1FO7DzB6F3oAWD5FRLF2iZGtOHllMxuamdc=";
  };
  VapourTheme = pkgs.fetchFromGitHub {
    owner = "ZagonAb";
    repo = "Vapour-Pegasus";
    rev = "master";
    hash = "sha256-7AZD3w7SyLqG3qmaT9gowPe9TVHSilnXRT6sDr7IMgM=";
  };
in
{
  home.file.".config/pegasus-frontend/themes/XboxOSv2" = {
    source = xboxTheme;
    recursive = true;
  };
  #   home.file.".config/pegasus-frontend/themes/gameOS" = {
  #     source = gameOSTheme;
  #     recursive = true;
  #   };
}
