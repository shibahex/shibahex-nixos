{ pkgs, ... }: {
  # libvirtd = { enable = true; };
  environment.systemPackages = with pkgs; [

    virt-manager
    virt-viewer

  ];
  virtualisation = {
    libvirtd = {

      enable = true;
      # qemu
    };
  };

}
