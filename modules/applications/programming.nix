{ pkgs, ... }:
{

  environment.systemPackages = with pkgs; [
    #Nushell is a terminal
    nushell
    arduino

    lazygit # for committing on github
    git
  ];
  # for Mason LSPs
  programs.nix-ld.enable = true;

}
