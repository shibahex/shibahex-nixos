{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })
    firefox
    fastfetch
    thunar
    ffmpegthumbnailer
    alacritty

    xenia-canary
    sc-controller

    pcsx2
    ryubing
    #partyDeck
    wineWowPackages.stable
    (rpcs3.overrideAttrs (prev: {
      cmakeFlags = prev.cmakeFlags ++ [ (lib.cmakeBool "BUILD_SHARED_LIBS" false) ];
    }))
    # Wrapper to start and close the skyrim server
    (writeShellScriptBin "skyrim-server" ''
      # Kill any existing processes with broader patterns
      pkill -9 -f "SkyrimTogether|TPPProcess|crashpad|wineserver"

      # Set up environment
      export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
      export STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/489830"

      # PID variable for the server process
      PID=""

      # Trap to kill server when script exits
      trap "kill $PID 2>/dev/null; pkill -9 -f 'SkyrimTogether|TPPProcess|crashpad|wineserver'" EXIT

      # Run the server in background and capture PID
      ${steam-run}/bin/steam-run "$HOME/.steam/steam/compatibilitytools.d/GE-Proton10-34/proton" run "$HOME/Steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn/SkyrimTogetherServer.exe" &
      PID=$!

      # Wait for the process to finish
      wait $PID

      # Kill any remaining processes with broader patterns when finished
      pkill -9 -f "SkyrimTogether|TPPProcess|crashpad|wineserver"
    '')
  ];
  # Enable Bluetooth
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = true;
    settings.General = {
      experimental = true; # show battery

      # https://www.reddit.com/r/NixOS/comments/1ch5d2p/comment/lkbabax/
      # for pairing bluetooth controller
      Privacy = "device";
      JustWorksRepairing = "always";
      Class = "0x000100";
      FastConnectable = true;
    };
  };
  services.blueman.enable = true;
  hardware.xpadneo.enable = true; # Enable the xpadneo driver for Xbox One wireless controllers
  hardware.xone.enable = true;
  hardware.steam-hardware.enable = true;
  boot.kernelModules = [
    "hid-sony"
    "hid-playstation"
  ];

  boot = {
    extraModulePackages = with config.boot.kernelPackages; [ xpadneo ];
    extraModprobeConfig = ''
      options bluetooth disable_ertm=Y
    '';
    # connect xbox controller
  };

  networking.firewall.enable = false;
  #recording
  programs.obs-studio = {
    enable = true;
  };

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;

  programs.gamemode.enable = true;
  virtualisation.docker.enable = true;
  networking.firewall.allowedTCPPorts = [
    11434
    47584
  ];
  networking.firewall.allowedUDPPorts = [ 47584 ];

}
