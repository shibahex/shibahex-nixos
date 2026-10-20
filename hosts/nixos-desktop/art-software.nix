{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    cudatoolkit
    # (blender.override { cudaSupport = true; })
    blender
    godot

  ];

  hardware.opentabletdriver.enable = true;
}
