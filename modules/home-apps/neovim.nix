{
  pkgs,
  config,
  lib,
  ...
}:
let
  nvimRepoUrl = "https://github.com/shibahex/LazyVim-starter.git";
  nvimRepoRev = "560a93f8e784bca4aac228fae671ma0bdfbbedf6";
  nvimLocalPath = "${config.home.homeDirectory}/Documents/LazyVim-starter";
in
{
  home.packages = [
    pkgs.neovim
    pkgs.gcc
    pkgs.xclip
    pkgs.ripgrep
    pkgs.git
  ];

  programs.neovim = {
    viAlias = true;
    vimAlias = true;
  };

  home.activation.cloneNvimConfig = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [ ! -d "${nvimLocalPath}" ]; then
      $DRY_RUN_CMD git clone ${nvimRepoUrl} "${nvimLocalPath}"
      cd "${nvimLocalPath}"
      $DRY_RUN_CMD git checkout ${nvimRepoRev}
    fi
  '';

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimLocalPath;
}
