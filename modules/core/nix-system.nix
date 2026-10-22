{
  host,
  lib,
  pkgs,
  stateVersion,
  self,
  ...
}:
let
  inherit (import "${self}/hosts/${host}/variables.nix" { pkgs = pkgs; }) timeZone;
in
{
  nix = {
    settings = {
      download-buffer-size = 250000000;
      # Dedup on a timer (nix.optimise) instead of after every build
      auto-optimise-store = false;
      # Each build uses every thread; max-jobs caps how many run at once so
      # several big C++/CUDA builds don't run out of RAM. Hosts can override.
      max-jobs = lib.mkDefault 4;
      cores = lib.mkDefault 0;
      substituters = [
        "https://nix-community.cachix.org"
        # Unfree CUDA builds aren't on cache.nixos.org
        "https://cache.nixos-cuda.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
      ];
      experimental-features = [
        "nix-command"
        "flakes"
      ];
    };
  };
  nix.optimise.automatic = lib.mkDefault true;
  nix.gc = {
    automatic = lib.mkDefault true;
    dates = lib.mkDefault "weekly";
    options = lib.mkDefault "--delete-older-than 14d";
  };
  nix.package = lib.mkDefault pkgs.nix;

  time.timeZone = lib.mkDefault timeZone;
  i18n.defaultLocale = lib.mkDefault "en_US.UTF-8";
  system.stateVersion = "${stateVersion}";
  nixpkgs.config.allowUnfree = lib.mkDefault true;
}
