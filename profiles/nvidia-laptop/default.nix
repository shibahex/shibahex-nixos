{
  lib,
  self,
  host,
  ...
}:
let
  inherit (import "${self}/hosts/${host}/variables.nix") intelID nvidiaID;
in
{
  imports = [ "${self}/modules/drivers" ];
  drivers.nvidia.enable = lib.mkDefault true;
  drivers.nvidia-prime = {
    enable = lib.mkDefault true;
    intelBusID = lib.mkDefault intelID;
    nvidiaBusID = lib.mkDefault nvidiaID;
  };
}
