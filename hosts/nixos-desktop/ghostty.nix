{ pkgs, ... }:
let
  variables = import ./variables.nix { pkgs = pkgs; };

in
{
  home-manager.users.${variables.hostName} = {
    programs.ghostty = {
      enable = true;
      settings = {
        background = "#000000";
        custom-shader = "${./shaders/testing.glsl}";
      };
    };

    # puts the .glsl file into ~/.config/ghostty/shaders/
    xdg.configFile."ghostty/shaders/retro-crt.glsl".source = ./shaders/retro-crt.glsl;
    xdg.configFile."ghostty/shaders/testing.glsl".source = ./shaders/testing.glsl;
  };
}
