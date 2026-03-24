{ pkgs, ... }:
{
  home.file.".config/nushell/nix-prompt.nu".text = ''
    if ($env.IN_NIX_SHELL? != null) {
        $env.PROMPT_INDICATOR = $" \(($env.IN_NIX_SHELL)\)> "
    }
  '';
  home.file.".config/nushell/env.nu".text = ''
    source ~/.config/nushell/nix-prompt.nu
  '';
  home.sessionVariables = {
    EDITOR = "neovim";
  };

  programs.nushell = {
    enable = true;
    extraConfig = ''
      $env.config.keybindings ++= [{
          name: ctrl_s_move_word_right
          modifier: control
          keycode: char_s
          mode: [emacs, vi_insert]
          event: {
              until: [
                  { send: historyhintwordcomplete }
                  { edit: movewordright }
              ]
          }
      }]
    '';
  };
}
