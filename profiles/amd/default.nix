{ lib, self, ... }:
{
  imports = [ "${self}/modules/drivers" ];
  drivers.amdgpu.enable = lib.mkDefault true;
}
