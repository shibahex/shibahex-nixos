{ inputs, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
  reaperPkgs = inputs.reaper-flake.packages.${system};
  # Wrap REAPER so every launch asks PipeWire for a 128-frame buffer.
  reaperLowLatency = pkgs.symlinkJoin {
    name = "reaper-lowlatency";
    paths = [ reaperPkgs.reaper ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/reaper \
      --set PIPEWIRE_LATENCY "128/48000"
    '';
  };
in
{
  imports = [ inputs.reaper-flake.homeModules.reaper ];

  nixpkgs.config.allowUnfree = true;

  programs.reaper = {
    enable = true;
    # configPath = "${config.xdg.configHome}/REAPER";

    theme = {
      active = "Reapertips Theme.ReaperThemeZip";
      packages = [ reaperPkgs.reapertips-theme ];
    };

    swell.colortheme = {
      enable = true;
      preset = reaperPkgs.reapertips-theme;
    };

    # Runtime libs some scripts/themes need (ReaImGui etc.)
    packages = with pkgs; [
      cairo
      fontconfig
      freetype
      glib
      gtk3
      libepoxy
      libpng
      zlib
    ];

    ini = {
      sections.reaper = {
        continuous_scrolling = true;
        # linux_audio_mode = 3;   # PulseAudio backend (PipeWire compat)
      };
    };

    extensions = {
      sws = {
        enable = true;
        colors = [
          "#F5E0E6"
          "#F2CDCD"
          "#F5C2E7"
          "#CBA6F7"
          "#F38BA8"
          "#EBA0AC"
          "#FAB387"
          "#F9E2AF"
          "#A6E3A1"
          "#94E2D5"
          "#89DCEB"
          "#74C7EC"
          "#89B4FA"
          "#B4BEFE"
          "#CDD6F4"
          "#BAC2DE"
        ];
      };

      reapack = {
        enable = true;
        addDefaultRepositories = true;
        installNewPackagesWhenSynchronizing = false;
        synchronizeOnActivation = true;
        repositories = [
          {
            name = "ReaTeam Scripts";
            installNewPackages = "manual";
            url = "https://github.com/ReaTeam/ReaScripts/raw/master/index.xml";
          }
          {
            name = "Saike Tools";
            installNewPackages = "manual";
            url = "https://raw.githubusercontent.com/JoepVanlier/JSFX/241ec8e46320484d87435d2bc0f1388bc520833f/index.xml";
          }
        ];
        packages = [
          {
            category = "Basics";
            name = "Transience.jsfx";
            repository = "Saike Tools";
          }
          {
            category = "Basics";
            name = "Tight_Compressor.jsfx";
            repository = "Saike Tools";
          }
          {
            repository = "ReaTeam Scripts";
            category = "MIDI Editor";
            name = "spk77_MIDI velocity tool.eel";
          }
          {
            repository = "ReaTeam Scripts";
            category = "MIDI Editor";
            name = "spk77_Set random velocities for selected notes.eel";
          }
        ];
      };
    };
  };
}
