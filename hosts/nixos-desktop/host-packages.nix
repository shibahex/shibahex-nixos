{ pkgs, ... }:
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

    # Recording App
    obs-studio

    # Discord
    vesktop

    # Extra browser
    librewolf

    #Yubikey
    yubikey-manager

    linuxPackages.usbip
  ];

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
    iptables -A INPUT -p tcp --dport 3240 -s 192.168.122.69 -j ACCEPT
    iptables -A INPUT -p tcp --dport 3240 -j DROP
  '';

  boot.kernelModules = [
    "usbip-core"
    "usbip-host"
  ];

  # services.wazuh-agent = {
  #   enable = true;
  #   # Add your Wazuh manager address
  #   managerAddress = "your-wazuh-manager.example.com";
  # };
}
