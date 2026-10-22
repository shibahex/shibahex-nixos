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
  # AnkiConnect with its API key read from ~/.config/anki-connect/api-key, so the key stays
  # out of this public repo and the world-readable Nix store. No file means no key.
  anki-connect = pkgs.ankiAddons.anki-connect.overrideAttrs (old: {
    postPatch = (old.postPatch or "") + ''
      cat >> util.py <<'EOF'

      _setting = setting

      def setting(key):
          if key == 'apiKey':
              try:
                  with open(os.path.expanduser('~/.config/anki-connect/api-key')) as f:
                      return f.read().strip() or None
              except FileNotFoundError:
                  pass
          return _setting(key)
      EOF
    '';
  });
in
{
  environment.systemPackages = with pkgs; [
    # anki-connect: lets the health dashboard and its Anki MCP reach the collection
    (anki.withAddons [
      ankiAddons.review-heatmap
      # Listens on every interface so the dashboard's other accounts can use this PC's LAN address
      # (they can't use localhost). Port 8765 stays closed in the firewall, so only this PC reaches it.
      (anki-connect.withConfig { config.webBindAddress = "0.0.0.0"; })
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

    jdk25
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
    settings.publish = {
      "disable-publishing" = false;
      disable-user-service-publishing = false;
      publish-addresses = true;
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
