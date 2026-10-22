# For any nix/system configuration
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
      # Parallel builds x threads per build. Leaving cores at 0 (all threads) with
      # many jobs oversubscribes the CPU and swaps big builds. Hosts can override.
      max-jobs = lib.mkDefault 4;
      cores = lib.mkDefault 4;
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
  nix.package = pkgs.nix;
  #nix.package = pkgs.lixPackageSets.stable.lix;

  time.timeZone = timeZone;
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "${stateVersion}";
  nixpkgs.config.allowUnfree = true;

}
