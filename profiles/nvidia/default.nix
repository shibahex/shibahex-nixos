{ lib, self, ... }:
{
  imports = [ "${self}/modules/drivers" ];
  drivers.nvidia.enable = lib.mkDefault true;
}
