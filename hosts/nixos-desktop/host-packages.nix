{ pkgs, ... }: {
  environment.systemPackages = with pkgs; [
    # Add host-specific packages here
    (anki.withAddons [ ankiAddons.review-heatmap ])
    # For timing tasks and productivity
    timer
    btop
  ];

  virtualisation.docker.enable = true;

  # services.wazuh-agent = {
  #   enable = true;
  #   # Add your Wazuh manager address
  #   managerAddress = "your-wazuh-manager.example.com";
  # };
}
