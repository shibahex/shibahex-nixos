{ lib, self, ... }:
{
  imports = [ "${self}/modules/drivers" ];
  drivers.intel.enable = lib.mkDefault true;
}
