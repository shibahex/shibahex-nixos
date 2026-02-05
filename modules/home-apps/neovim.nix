{ pkgs, ... }:

let
  neovimConfig = pkgs.fetchFromGitHub {
    owner = "shibahex";
    repo = "kickstart.nvim";
    sha256 = "1sbbdxrnsc67zqw6qkm2mahvlp6hvbld4rxbm2zqixf2diccb638";
    rev = "e3263d9cecaf27e7da88107ae23d58149827e9de";
  };
in
{

  home.packages = [
    pkgs.neovim
    pkgs.gcc
    pkgs.xclip
    pkgs.ripgrep
    # Deno is for Peek (markdown viewer for neovim)
    pkgs.deno
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

  home.sessionVariables = { EDITOR = "nvim"; };
}
