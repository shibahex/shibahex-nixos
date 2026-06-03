{ pkgs, ... }:
let
  xboxTheme = pkgs.fetchFromGitHub {
    owner = "luxureousproductions-bit";
    repo = "XboxOSv2";
    rev = "master";
    hash = "sha256-C3sCpqNFlhof8fZXv77YyGRmOFK06pJ4SJowx2lHg6k=";
  };
  gameOS = pkgs.fetchFromGitHub {
    owner = "shibahex";
    repo = "gameOS";
    rev = "master";
    hash = "sha256-JR6W2L+gpTY8JOJGcmUcNmAutpAXnFOe8ifPlXNlRjA=";
  };
  VapourTheme = pkgs.fetchFromGitHub {
    owner = "ZagonAb";
    repo = "Vapour-Pegasus";
    rev = "master";
    hash = "sha256-7AZD3w7SyLqG3qmaT9gowPe9TVHSilnXRT6sDr7IMgM=";
  };
in
{
  home.file.".config/pegasus-frontend/themes/gameOS" = {
    source = gameOS;
    recursive = true;
  };
  #   home.file.".config/pegasus-frontend/themes/gameOS" = {
  #     source = gameOSTheme;
  #     recursive = true;
  #   };
}
