{ pkgs, ... }: {
  # libvirtd = { enable = true; };
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    looking-glass-client
  ];
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true; # Enable software TPM
      };
    };
  };

  # Looking glass
  systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 $USER kvm -" ];

}
