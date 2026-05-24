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
