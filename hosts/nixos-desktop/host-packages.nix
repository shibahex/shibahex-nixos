{ config
, pkgs
, inputs
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
    tmux
    openvpn
    # Discord
    vesktop
    # Extra browser
    librewolf
    #Yubikey
    yubikey-manager
    linuxPackages.usbip
    fastfetch
    thunar
    ffmpegthumbnailer

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

    # VPN
    wireguard-tools
  ];
  # rd2
  hardware.opengl.driSupport32Bit = true;
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    glibc_multi
  ];
  # Try to fix wireless keyboard disconnecting on sleep
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0c45", ATTR{idProduct}=="fefe", TEST=="power/control", ATTR{power/control}="on"
  '';
  #TODO: make below into more nix files
  services.playerctld.enable = true;

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;
  # for looking glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 $USER kvm -" ];
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
  networking.firewall.extraCommands = ''
    iptables -A INPUT -p tcp --dport 3240 -s 192.168.122.62 -j ACCEPT
    iptables -A INPUT -p tcp --dport 3240 -j DROP
  '';
  boot.kernelModules = [
    "usbip-core"
    "usbip-host"
  ];

  # For keyboard
  hardware.keyboard.qmk.enable = true;
  services.udev.packages = [ pkgs.via ];

  # Ram Categories
  imports = [
    ./ram-management.nix
  ];
}
