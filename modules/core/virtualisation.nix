{
  pkgs,
  lib,
  config,
  username,
  ...
}:
let
  cfg = config.modules.virtualisation;
in
{
  options.modules.virtualisation = {
    enable = lib.mkEnableOption "libvirt and virt-manager";
    swtpm = lib.mkEnableOption "software TPM support";
    lookingGlass = lib.mkOption {
      type = lib.types.bool;
      default = cfg.enable;
      description = "Looking Glass client and its shared-memory file.";
    };
    vfio = {
      enable = lib.mkEnableOption "GPU passthrough with VFIO";
      ids = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        default = [ ];
        example = [
          "10de:1b06"
          "10de:10ef"
        ];
        description = "PCI vendor:device IDs bound to vfio-pci at boot (GPU and its audio function).";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      environment.systemPackages = with pkgs; [
        virt-manager
        virt-viewer
      ];

      virtualisation.libvirtd = {
        enable = lib.mkDefault true;
        qemu.swtpm.enable = cfg.swtpm;
      };

      users.users."qemu-libvirtd".extraGroups = [
        "render"
        "video"
        "kvm"
      ];
    })
    (lib.mkIf cfg.lookingGlass {
      environment.systemPackages = [ pkgs.looking-glass-client ];
      systemd.tmpfiles.rules = [ "f /dev/shm/looking-glass 0660 ${username} kvm -" ];
    })
    (lib.mkIf cfg.vfio.enable {
      boot.kernelParams = [
        "iommu=pt"
      ]
      # AMD enables its IOMMU by default; Intel needs it turned on
      ++ lib.optional config.hardware.cpu.intel.updateMicrocode "intel_iommu=on"
      ++ lib.optional (cfg.vfio.ids != [ ]) "vfio-pci.ids=${lib.concatStringsSep "," cfg.vfio.ids}";
    })
  ];
}
