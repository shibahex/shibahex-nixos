{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  variables = import ./variables.nix { pkgs = pkgs; };
in
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # ============================================================
  # KERNEL
  # ============================================================
  boot.kernelParams = [
    "intel_iommu=on"
    "iommu=pt"
    "vfio-pci.ids=${variables.vfioIds}"
  ];
  boot.blacklistedKernelModules = [ "nouveau" ]; # Let nvidia take over
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];

  # ============================================================
  # ENCRYPTION
  # ============================================================
  # Root SSD (nvme1n1p2)
  boot.initrd.luks.devices."luks-49b6cc8e-a559-4748-b78a-dad3b31f2325".device =
    "/dev/disk/by-uuid/49b6cc8e-a559-4748-b78a-dad3b31f2325";
  # HDD (sda)
  boot.initrd.luks.devices."hdd".device = "/dev/disk/by-uuid/746c375d-6a9e-46c8-909c-115ee042763e";
  # SSD_2 (nvme0n1)
  boot.initrd.luks.devices."SSD_2".device = "/dev/disk/by-uuid/6b311499-7121-4183-8dba-59881bc07696";

  # ============================================================
  # FILESYSTEMS
  # ============================================================

  # Root (btrfs subvolumes on nvme1n1p2)
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/226c330a-fb06-480a-8292-33e74dc053a8";
    fsType = "btrfs";
    options = [ "subvol=@" "compress=zstd" "noatime" "ssd" ];
  };
  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/226c330a-fb06-480a-8292-33e74dc053a8";
    fsType = "btrfs";
    options = [ "subvol=@home" "compress=zstd" "noatime" "ssd" ];
  };
  fileSystems."/var/log" = {
    device = "/dev/disk/by-uuid/226c330a-fb06-480a-8292-33e74dc053a8";
    fsType = "btrfs";
    options = [ "subvol=@var-log" "compress=zstd" "noatime" "ssd" ];
  };

  # Boot
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/8C78-571B";
    fsType = "vfat";
    options = [ "fmask=0077" "dmask=0077" ];
  };

  # ============================================================
  # HDD (sda) — 1.8T root mount
  # ============================================================
  fileSystems."/mnt/HDD" = {
    device = "/dev/mapper/hdd";
    fsType = "btrfs";
    options = [ "compress=zstd" "noatime" "nossd" "nofail" ];
  };

  # ============================================================
  # SSD_2 (nvme0n1) — 954G
  # ============================================================
  fileSystems."/home/shiba/SteamLibrary" = {
    device = "/dev/mapper/SSD_2";
    fsType = "btrfs";
    options = [ "subvol=@steam" "compress=zstd:1" "noatime" "nofail" "ssd" ];
  };
  fileSystems."/home/shiba/Projects" = {
    device = "/dev/mapper/SSD_2";
    fsType = "btrfs";
    options = [ "subvol=@projects" "compress=zstd" "noatime" "nofail" "ssd" ];
  };
  fileSystems."/home/shiba/vmImages" = {
    device = "/dev/mapper/SSD_2";
    fsType = "btrfs";
    options = [ "subvol=@vmimages" "noatime" "nofail" "ssd" ];
  };

  # ============================================================
  # HDD (sda) — 1.8T subvolumes
  # ============================================================
  fileSystems."/home/shiba/Documents" = {
    device = "/dev/mapper/hdd";
    fsType = "btrfs";
    options = [ "subvol=@documents" "compress=zstd" "noatime" "nofail" "nossd" ];
  };
  fileSystems."/home/shiba/Downloads" = {
    device = "/dev/mapper/hdd";
    fsType = "btrfs";
    options = [ "subvol=@downloads" "compress=zstd" "noatime" "nofail" "nossd" ];
  };
  fileSystems."/home/shiba/Ebooks" = {
    device = "/dev/mapper/hdd";
    fsType = "btrfs";
    options = [ "subvol=@ebooks" "compress=zstd" "noatime" "nofail" "nossd" ];
  };
  fileSystems."/home/shiba/Pictures" = {
    device = "/dev/mapper/hdd";
    fsType = "btrfs";
    options = [ "subvol=@pictures" "compress=zstd" "noatime" "nofail" "nossd" ];
  };
  fileSystems."/home/shiba/Videos" = {
    device = "/dev/mapper/hdd";
    fsType = "btrfs";
    options = [ "subvol=@videos" "compress=zstd" "noatime" "nofail" "nossd" ];
  };

  # ============================================================
  # MISC
  # ============================================================
  swapDevices = [ ];
  networking.useDHCP = lib.mkDefault true;
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
