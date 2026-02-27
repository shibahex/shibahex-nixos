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
  ];

  # for looking glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 $USER kvm -" ];

  programs.gamemode.enable = true;
  virtualisation.docker.enable = true;

  powerManagement.cpuFreqGovernor = "performance";
  # services.wazuh-agent = {
  #   enable = true;
  #   # Add your Wazuh manager address
  #   managerAddress = "your-wazuh-manager.example.com";
  # };
}
