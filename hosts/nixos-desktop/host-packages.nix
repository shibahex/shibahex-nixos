{
  pkgs,
  inputs,
  username,
  ...
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
    # anki-connect: lets the health dashboard and its Anki MCP reach the collection
    (anki.withAddons [
      ankiAddons.review-heatmap
      ankiAddons.anki-connect
    ])
    timeshift
    timer
    btop
    freerdp
    mangohud
    qsynth
    mpv
    alacritty
    tmux
    openvpn
    (vesktop.override { withSystemVencord = false; })
    grayjay

    fastfetch

    rpcs3

    # MPRIS control, used for lyrics
    playerctl

    pstree

    obsidian
    taskwarrior3
    taskwarrior-tui

    via

    yt-dlp
    #noctalia shell plugin for lyrics
    lyricsmpris

    pegasus-frontend

    wireguard-tools
    claude-code
    repomix
  ];

  programs.wireshark.enable = true;
  users.users.${username} = {
    extraGroups = [
      "wireshark"
      "dialout"
    ];
  };

  # Avahi for network discovery (Moonlight clients find Sunshine via mDNS)
  services.avahi = {
    enable = true;
    publish = {
      enable = true;
      userServices = true;
    };
  };

  services.playerctld.enable = true;

  imports = [
    ./configuration
    ./art-software.nix
  ];

  # Fixes niri freezing on the Nvidia driver
  boot.extraModprobeConfig = ''
    options nvidia NVreg_PreserveVideoMemoryAllocations=1 NVreg_UsePageAttributeTable=1
  '';
}
