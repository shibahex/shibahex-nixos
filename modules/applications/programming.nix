{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lazygit # for committing on github
    git
    unzip
  ];

  # for Mason LSPs
  programs.nix-ld.enable = true;
}
