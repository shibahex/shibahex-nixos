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
    reaper-flake = {
      url = "github:9Prestidigitator/reaper-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    partydeckfork = {
      url = "github:cseelhoff/partydeck";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs =
    {
      nixpkgs,
      stylix,
      self,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      localPackagesOverlay = final: prev: {
        partyDeck = final.callPackage ./pkgs/partydeck/package.nix { };
        # Workarounds: these fail to build with GCC 16
        breakpad = prev.breakpad.override { stdenv = prev.gcc14Stdenv; };
        pegasus-frontend = prev.pegasus-frontend.override { stdenv = prev.gcc14Stdenv; };
      };
      mkHost =
        {
          hostname,
          profile,
          username,
          stateVersion,
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
            {
              nixpkgs.overlays = [
                localPackagesOverlay
              ];
            }
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
