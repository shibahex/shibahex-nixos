{
  description = "ShibaHex Nix (File format based on Don OS)";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Last nixpkgs on Qt 6.11; noctalia-shell fails to build against Qt 6.12
    # (noctalia-dev/noctalia#4761). Drop this once upstream is fixed.
    nixpkgs-noctalia.url = "github:nixos/nixpkgs/6774f7bc253789b113a4f39285dc0fa100abeacc";
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
        # Pinned to the Qt 6.11 nixpkgs, see the nixpkgs-noctalia input
        noctalia-shell = inputs.nixpkgs-noctalia.legacyPackages.${system}.noctalia-shell;
        # Workaround: fails to build with GCC 16
        pegasus-frontend = prev.pegasus-frontend.override { stdenv = prev.gcc14Stdenv; };
        # Workaround: aggregator now requires a .ko.cer per out-of-tree module
        # (virtualbox-modules, vmware-modules, ...) that most don't produce,
        # aborting the whole modules closure. nixpkgs#575192, still open.
        aggregateModules =
          modules:
          (prev.aggregateModules modules).overrideAttrs (old: {
            postBuild = prev.lib.replaceStrings
              [ ''| xargs -d'\n' cat >> modules.cer'' ]
              [ ''| xargs -d'\n' cat >> modules.cer || true'' ]
              old.postBuild;
          });
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
