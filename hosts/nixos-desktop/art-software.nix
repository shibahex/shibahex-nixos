{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    krita
    cudatoolkit
    (blender.override { cudaSupport = true; })
    godot

  ];

  hardware.opentabletdriver.enable = true;
}
