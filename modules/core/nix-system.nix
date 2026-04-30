# For any nix/system configuration
{ host
, pkgs
, stateVersion
, ...
}:
let
  inherit (import ../../hosts/${host}/variables.nix { pkgs = pkgs; }) timeZone;
in
{
  nix = {
    settings = {
      download-buffer-size = 250000000;
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  nix.package = pkgs.nix;
  #nix.package = pkgs.lixPackageSets.stable.lix;

  time.timeZone = timeZone;
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "${stateVersion}";
  nixpkgs.config.allowUnfree = true;

}
