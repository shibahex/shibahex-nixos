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
        background-opacity = 0.95;
        custom-shader = "${./shaders/retro-glow.glsl}";
        theme = "Darkside";
      };
    };
    stylix.targets.ghostty.enable = false;

    # puts the .glsl file into ~/.config/ghostty/shaders/
    xdg.configFile."ghostty/shaders/retro-glow.glsl".source = ./shaders/retro-glow.glsl;
    xdg.configFile."ghostty/shaders/retro-crt.glsl".source = ./shaders/retro-crt.glsl;
    xdg.configFile."ghostty/shaders/testing.glsl".source = ./shaders/testing.glsl;
  };
}
