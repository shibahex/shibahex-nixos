{
  pkgs,
  config,
  lib,
  ...
}:
let
  nvimRepoUrl = "https://github.com/shibahex/LazyVim-starter.git";
  nvimRepoRev = "44c6601901d5722a9fbf63228cc83a820a2e6d6b";
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
      $DRY_RUN_CMD ${pkgs.git}/bin/git clone ${nvimRepoUrl} "${nvimLocalPath}"
      cd "${nvimLocalPath}"
      $DRY_RUN_CMD ${pkgs.git}/bin/git checkout ${nvimRepoRev}
    fi
  '';

  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimLocalPath;
}
