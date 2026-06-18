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

    xenia-canary
    pegasus-frontend

    # VPN
    wireguard-tools

    # WRAPPED fuse-overlayfs: Forces it to use the SUID wrapper
    (pkgs.writeShellScriptBin "fuse-overlayfs" ''
      exec ${pkgs.fuse-overlayfs}/bin/fuse-overlayfs --fusermount=/run/wrappers/bin/fusermount3 "$@"
    '')

    bash
    mimalloc

    mesa-demos
    jan
  ];
  programs.nix-ld.enable = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  programs.gamescope.enable = true;

  services.sunshine = {
    enable = true;
    autoStart = true;
    capSysAdmin = true; # needed for KMS display capture
    openFirewall = true;
    package = pkgs.sunshine.override {
      cudaSupport = true;
      cudaPackages = pkgs.cudaPackages;
    };
  };

  security.pki.certificateFiles = [
    "${self}/certs/step-root-ca.crt"
  ];
  environment.variables = {
    SSL_CERT_FILE = "/etc/ssl/certs/ca-certificates.crt";
    SSL_CERT_DIR = "/etc/ssl/certs/";
  };

  networking.extraHosts = ''
    10.1.0.236 ai-agent.adams.internal
  '';

  # Avahi for network discovery (Moonlight clients find Sunshine via mDNS)
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };
  # FOR PARTYDECK and Moonlight
  networking.firewall.allowedUDPPorts = [
    47584
    48000
    48010
  ];
  networking.firewall.allowedTCPPorts = [
    47584
    48010
  ];

  networking.hosts = {
    "127.0.0.1" = [ "gconnect.ubi.com" ];
  };

  # Try to fix wireless keyboard disconnecting on sleep
  services.udev.extraRules = ''
    ACTION=="add", SUBSYSTEM=="usb", ATTR{idVendor}=="0c45", ATTR{idProduct}=="fefe", TEST=="power/control", ATTR{power/control}="on"
  '';
  #TODO: make below into more nix files
  services.playerctld.enable = true;

  # ffmpegthumbnailer and tumbler for mp4 thumbnails
  services.tumbler.enable = true;
  # for looking glass and steam start scripts
  systemd.tmpfiles.rules = [
    "L+ /sbin/ldconfig - - - - ${pkgs.glibc}/sbin/ldconfig"
    "f /dev/shm/looking-glass 0660 shiba kvm -"
  ];
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
