{ lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    lazygit
    git
    unzip
  ];

  # Lets Mason's prebuilt LSP binaries run
  programs.nix-ld.enable = lib.mkDefault true;
}
