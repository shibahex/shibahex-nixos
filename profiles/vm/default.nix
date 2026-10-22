{ lib, self, ... }:
{
  imports = [ "${self}/modules/drivers" ];
  vm.guest-services.enable = lib.mkDefault true;
}
