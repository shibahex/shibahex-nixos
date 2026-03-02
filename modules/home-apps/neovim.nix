{ pkgs, ... }:

let
  neovimConfig = pkgs.fetchFromGitHub {
    owner = "shibahex";
    repo = "LazyVim-starter";
    sha256 = "sha256-PJ7iB9yggq7ktwXA9GAVeq8ZXSFtJcj+e1+9uQ46ESo=";
    rev = "bfbafe900eb5d80d949c9c202e624e19c994341a";
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
        $env.PROMPT_INDICATOR = $" \(($env.IN_NIX_SHELL)\)> "
    }
  '';
  home.file.".config/nushell/env.nu".text = ''
    source ~/.config/nushell/nix-prompt.nu
  '';
  home.sessionVariables = {
    EDITOR = "nvim";
  };
}
