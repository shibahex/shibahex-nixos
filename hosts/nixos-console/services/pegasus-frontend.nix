{ pkgs, ... }:
let
  xboxTheme = pkgs.fetchFromGitHub {
    owner = "luxureousproductions-bit";
    repo = "XboxOSv2";
    rev = "master";
    hash = "sha256-C3sCpqNFlhof8fZXv77YyGRmOFK06pJ4SJowx2lHg6k=";
  };
in
{
  environment.systemPackages = with pkgs; [ pegasus-frontend ];
  _module.args.xboxTheme = xboxTheme;
}
