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
  vapourTheme = pkgs.fetchFromGitHub {
    owner = "ZagonAb";
    repo = "Vapour-Pegasus";
    rev = "master";
    hash = "sha256-7AZD3w7SyLqG3qmaT9gowPe9TVHSilnXRT6sDr7IMgM=";
  };
  flatFlix = pkgs.fetchFromGitHub {
    owner = "ZagonAb";
    repo = "FlatFlix";
    rev = "master";
    hash = "sha256-S8v/kXdt2q1NOc9PIqsqZLbiyRWTWMaEa/ttPvu3i2c=";
  };
  # https://github.com/pixl-os/gameOS
  gameOsFork = pkgs.fetchFromGitHub {
    owner = "rift-themes";
    repo = "gameOS-qt6";
    rev = "master";
    hash = "sha256-gxtWHjZwogC4YcJHShS/xB65C6larqZLyx8TQ1r9UPk=";
  };

in
{
  home.file.".config/pegasus-frontend/themes/XboxOSv2" = {
    source = xboxTheme;
    recursive = true;
  };
  # home.file.".config/pegasus-frontend/themes/gameOS" = {
  #   source = gameOSTheme;
  #   recursive = true;
  # };
  # home.file.".config/pegasus-frontend/themes/gameOS" = {
  #   source = gameOSTheme;
  #   recursive = true;
  # };
  home.file.".config/pegasus-frontend/themes/FlatFlix" = {
    source = flatFlix;
    recursive = true;
  };
}
