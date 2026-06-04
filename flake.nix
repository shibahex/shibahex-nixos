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
    plasma67.url = "github:abdelq/nixpkgs/abdelq/oqyynsqtkmqv";
  };
  outputs =
    { nixpkgs
    , stylix
    , self
    , plasma67
    , ...
    }@inputs:
    let
      system = "x86_64-linux";
      localPackagesOverlay = final: prev: {
        sunshine = final.callPackage ./pkgs/sunshine/package.nix { };
        gamescope-kbm = final.callPackage ./pkgs/gamescope-kbm/package.nix { };
        partyDeck = final.callPackage ./pkgs/partydeck/package.nix { };
      };
      plasma67Overlay = final: prev: {
        kdePackages = plasma67.legacyPackages.${system}.kdePackages;
      };
      plasma67Module =
        { config, lib, ... }:
        {
          options.services.desktopManager.plasma6Bigscreen = {
            enable = lib.mkOption {
              type = lib.types.bool;
              default = false;
              description = "Enable Plasma Big Screen (KDE for large displays)";
            };
          };
          config = lib.mkIf config.services.desktopManager.plasma6Bigscreen.enable {
            services.desktopManager.plasma6.enable = true;
            services.displayManager.sessionPackages = [
              plasma67.legacyPackages.${system}.kdePackages.plasma-bigscreen
            ];
            services.displayManager.defaultSession = "plasma-bigscreen-wayland";
            environment.systemPackages = with plasma67.legacyPackages.${system}.kdePackages; [
              plasma-bigscreen
              plasma-nm
              powerdevil
              kdeconnect-kde
            ];
          };
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
            plasma67Module
            {
              nixpkgs.overlays = [
                localPackagesOverlay
                plasma67Overlay
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
