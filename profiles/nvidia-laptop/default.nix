{ self, host, ... }:
let
  inherit (import "${self}/hosts/${host}/variables.nix") intelID nvidiaID;
in
{
  imports = [
    "${self}/modules/drivers"
  ];
  # Enable GPU Drivers
  drivers.amdgpu.enable = false;
  drivers.nvidia.enable = true;
  drivers.nvidia-prime = {
    enable = true;
    intelBusID = "${intelID}";
    nvidiaBusID = "${nvidiaID}";
  };
  drivers.intel.enable = false;
  vm.guest-services.enable = false;
}
