{ config
, pkgs
, inputs
, self
, ...
}:
let
  lyricsmpris = pkgs.rustPlatform.buildRustPackage {
    pname = "lyricsmpris";
    version = "unstable";
    src = inputs.lyricsmpris-rust;
    cargoLock.lockFile = "${inputs.lyricsmpris-rust}/Cargo.lock";
    buildInputs = [
      pkgs.dbus
      pkgs.openssl
    ];
    nativeBuildInputs = [ pkgs.pkg-config ];
  };
in
{
  modules.virtualisation = {
    enable = true;
    swtpm = true;
  };
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
    (anki.withAddons [ ankiAddons.review-heatmap ])
    # For timing tasks and productivity
    timer
    btop
    looking-glass-client
    freerdp
    mangohud
    mpv
    alacritty
    tmux
    openvpn
    # Discord
    (vesktop.override { withSystemVencord = false; })
    grayjay

    #Yubikey
    yubikey-manager
    linuxPackages.usbip

    fastfetch

    thunar
    ffmpegthumbnailer

    (rpcs3.overrideAttrs (prev: {
      cmakeFlags = prev.cmakeFlags ++ [ (lib.cmakeBool "BUILD_SHARED_LIBS" false) ];
    }))

    # Recording (make OBS see nvidiaPackages)
    (pkgs.writeShellScriptBin "obs" ''
      export LD_LIBRARY_PATH=${config.boot.kernelPackages.nvidiaPackages.stable}/lib:$LD_LIBRARY_PATH
      exec ${pkgs.obs-studio}/bin/obs "$@"
    '')

    # Playerctl for MPRIS (lyrics)
    playerctl

    # Way to find PIDs and see what taking RAM
    pstree

    obsidian
    taskwarrior3
    taskwarrior-tui

    #keyboard
    via

    #noctalia shell plugin for lyrics
    lyricsmpris

    pegasus-frontend

    # VPN
    wireguard-tools
    terax
  ];

  # Avahi for network discovery (Moonlight clients find Sunshine via mDNS)
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.playerctld.enable = true;

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;

  programs.gamemode.enable = true;
  virtualisation.docker.enable = true;
  powerManagement.cpuFreqGovernor = "performance";
  # USB Yubikey to VM. (Can be insecure if public)
  systemd.services.usbipd = {
    enable = true;
    description = "USB/IP Daemon";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.linuxPackages.usbip}/bin/usbipd";
      Restart = "on-failure";
    };
  };
  boot.kernelModules = [
    "usbip-core"
    "usbip-host"
  ];

  # Ram Categories
  imports = [
    ./configuration
  ];
}
