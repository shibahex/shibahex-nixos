{
  description = "ShibaHex Nix (File format based on Don OS)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    niri-scratchpad-flake = {
      url = "github:gvolpe/niri-scratchpad";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:nix-community/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lyricsmpris-rust = {
      url = "github:BEST8OY/LyricsMPRIS-Rust";
      flake = false;
    };
  };
  outputs =
    { nixpkgs
    , stylix
    , self
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      # Helper function to create a host configuration

      # sunshine package out of date.
      sunshineOverlay = final: prev: {
        sunshine = prev.sunshine.overrideAttrs (old: rec {
          version = "2026.516.143833";
          src = prev.fetchFromGitHub {
            owner = "LizardByte";
            repo = "Sunshine";
            tag = "v${version}";
            hash = "sha256-uRagpVR+lkOcXqodU5Z4+22WVr0kjdfE2EC7ZuQzODY=";
            fetchSubmodules = true;
          };
          passthru = old.passthru // {
            ui = old.passthru.ui.overrideAttrs (_: {
              inherit src;
              npmDepsHash = "sha256-YnNnuAdj/S5LGNytqIsmCApIec8DTWKF6VIJ7AXUctU=";
            });
          };
        });
      };
      mkHost =
        { hostname
        , profile
        , username
        , stateVersion
        ,
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs;
            host = hostname;
            inherit stateVersion;
            inherit self;
            inherit profile;
            inherit username;
          };
          modules = [
            ./hosts/${hostname}
            ./profiles/${profile}
            ./modules/applications
            ./modules/core
            ./modules/desktop
            stylix.nixosModules.stylix
            { nixpkgs.overlays = [ sunshineOverlay ]; }
          ];
        };
    in
    {
      nixosConfigurations = {
        # Users will create their own host configurations during installation
        cyber-vm = mkHost {
          hostname = "cyber-vm";
          profile = "nvidia";
          username = "sheeb";
          stateVersion = "26.05";
        };
        nixos-desktop = mkHost {
          hostname = "nixos-desktop";
          profile = "nvidia";
          username = "shiba";
          stateVersion = "25.05";
        };
        nixos-console = mkHost {
          hostname = "nixos-console";
          profile = "nvidia";
          username = "cuda";
          stateVersion = "26.05";
        };
        thinkpad-nix = mkHost {
          hostname = "thinkpad-nix";
          profile = "intel";
          username = "gecko";
          stateVersion = "25.11";
        };
      };
    };
}
