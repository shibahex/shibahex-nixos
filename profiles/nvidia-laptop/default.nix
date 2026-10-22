{ lib, self, ... }:
{
  imports = [ "${self}/modules/drivers" ];
  drivers.nvidia.enable = lib.mkDefault true;
  # Set drivers.nvidia-prime.{intelBusID,nvidiaBusID} in the host
  drivers.nvidia-prime.enable = lib.mkDefault true;
}
