# For any nix/system configuration
{ host, pkgs, ... }:
let
  inherit (import ../../hosts/${host}/variables.nix { pkgs = pkgs; }) timeZone;
in
{
  nix = {
    settings = {
      download-buffer-size = 250000000;
      auto-optimise-store = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
  };
  time.timeZone = timeZone;
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "25.11";
  nixpkgs.config.allowUnfree = true;

}
