{ pkgs, ... }:
{
  home.file.".config/nushell/nix-prompt.nu".text = ''
    if ("IN_NIX_SHELL" in $env) {
        $env.PROMPT_INDICATOR = $" \(($env.IN_NIX_SHELL)\)> "
    }
  '';
  programs.nushell = {
    enable = true;
    environmentVariables = {
      EDITOR = "nvim";
    };
    extraEnv = ''
      source ~/.config/nushell/nix-prompt.nu
    '';
    extraConfig = ''
      $env.config = {
        show_banner: false
        keybindings: [
          {
            name: ctrl_s_hint_word_complete
            modifier: control
            keycode: char_s
            mode: [emacs vi_insert vi_normal]
            event: {
              until: [
                { send: historyhintwordcomplete }
                { edit: movewordright }
              ]
            }
          }
        ]
      }
    '';
  };
}
