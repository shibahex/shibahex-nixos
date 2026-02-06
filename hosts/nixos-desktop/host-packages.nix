{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
    (anki.withAddons [ ankiAddons.review-heatmap ])
    # For timing tasks and productivity
    timer
    btop

    looking-glass-client
    freerdp
  ];

  # for looking glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 $USER kvm -" ];

  virtualisation.docker.enable = true;

  # services.wazuh-agent = {
  #   enable = true;
  #   # Add your Wazuh manager address
  #   managerAddress = "your-wazuh-manager.example.com";
  # };
}
