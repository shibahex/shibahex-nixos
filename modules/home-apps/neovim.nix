{ pkgs, ... }:

let
  neovimConfig = pkgs.fetchFromGitHub {
    owner = "shibahex";
    repo = "LazyVim-starter";
    sha256 = "sha256-flvrTwDjVTQyyqBvyq3f/DTjatjHCxdplVa5DFBc4Ts=";
    rev = "cefae95b3c9f04ecfe7d8738e9c32392e921ce0c";
  };
in {

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

  home.file.".config/nushell/nix-prompt.nu".text = ''
    if ($env.IN_NIX_SHELL? != null) {
        $env.PROMPT_INDICATOR = $"\(❄️($env.IN_NIX_SHELL)\) > "
    }
  '';
  home.file.".config/nushell/env.nu".text = ''
    source ~/.config/nushell/nix-prompt.nu
  '';
  home.sessionVariables = { EDITOR = "nvim"; };
}
