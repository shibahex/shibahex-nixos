{
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.modules.docker;
in
{
  options.modules.docker = {
    enable = lib.mkEnableOption "Docker";
    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = config.drivers.nvidia.enable;
      description = "GPU access in containers through nvidia-container-toolkit.";
    };
  };

  config = lib.mkIf cfg.enable {
    virtualisation.docker.enable = lib.mkDefault true;
    hardware.nvidia-container-toolkit.enable = cfg.nvidia;
    users.users.${username}.extraGroups = [ "docker" ];
  };
}
