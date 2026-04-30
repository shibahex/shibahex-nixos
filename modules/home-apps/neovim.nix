{ pkgs, ... }:

let
  neovimConfig = pkgs.fetchFromGitHub {
    owner = "shibahex";
    repo = "LazyVim-starter";
    sha256 = "sha256-AW2lFbGewmne45sgM6xJ25UDRRkQIQcTPP/Y9UhcZNA=";
    rev = "7a4d880605356abfba486c996a70ad951746e53f";
  };

  #neovimConfig = "/home/shiba/Documents/LazyVim-starter";
in
{

  home.packages = [
    pkgs.neovim
    pkgs.gcc
    pkgs.xclip
    pkgs.ripgrep
    # Deno is for Peek (markdown viewer for neovim)
    #pkgs.deno
  ];

  programs.neovim = {
    #enable = true;
    viAlias = true;
    vimAlias = true;
  };

  home.file.".config/nvim" = {
    source = neovimConfig;
    recursive = true;
  };

}
