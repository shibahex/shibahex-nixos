{ pkgs, config, ... }:
{
  environment.systemPackages = with pkgs; [
    btop
    (mpv.override { yt-dlp = pkgs.yt-dlp-light; })
    firefox
    fastfetch
    alacritty

    xenia-canary
    sc-controller

    pcsx2
    ryubing
    partyDeck
    rpcs3
    # wineWowPackages.stable
    # (rpcs3.overrideAttrs (prev: {
    #   cmakeFlags = prev.cmakeFlags ++ [ (lib.cmakeBool "BUILD_SHARED_LIBS" false) ];
    # }))

    (writeShellScriptBin "skyrim-server" ''
      pkill -9 -f "SkyrimTogether|TPPProcess|crashpad|wineserver"

      export STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.local/share/Steam"
      export STEAM_COMPAT_DATA_PATH="$HOME/.local/share/Steam/steamapps/compatdata/489830"

      PID=""

      trap "kill $PID 2>/dev/null; pkill -9 -f 'SkyrimTogether|TPPProcess|crashpad|wineserver'" EXIT

      ${steam-run}/bin/steam-run "$HOME/.steam/steam/compatibilitytools.d/GE-Proton10-34/proton" run "$HOME/Steam/steamapps/common/Skyrim Special Edition/Data/SkyrimTogetherReborn/SkyrimTogetherServer.exe" &
      PID=$!

      wait $PID

      pkill -9 -f "SkyrimTogether|TPPProcess|crashpad|wineserver"
    '')
    swayidle
    kdePackages.libkscreen

  ];

  hardware.bluetooth = {
    enable = true;
    input = {
      General = {
        IdleTimeout = 45;
      };
    };
  };

  systemd.user.services.swayidle = {
    description = "swayidle - turn off display after idle";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];
    serviceConfig = {
      ExecStart = ''
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 300 '${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor --dpms off' \
          resume     '${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor --dpms on'
      '';
      Restart = "on-failure";
    };
    environment = {
      QT_QPA_PLATFORM = "wayland";
      WAYLAND_DISPLAY = "wayland-0";
    };
  };
}
