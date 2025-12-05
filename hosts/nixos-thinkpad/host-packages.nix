{ pkgs, ... }: {
  environment.systemPackages = with pkgs;
    [
      # Add host-specific packages here
      (anki.withAddons [ ankiAddons.review-heatmap ])
    ];
}
