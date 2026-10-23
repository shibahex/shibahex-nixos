{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
    kernelModules = [ "v4l2loopback" ];
    # Kernel's `dev` output now ships System.map, so kbuild's modules_install
    # runs depmod for out-of-tree modules too; v4l2loopback's own modules.alias
    # then collides with the kernel's when NixOS merges them (nixpkgs#576406).
    # DEPMOD=true no-ops that depmod call; the final aggregate depmod handles it.
    extraModulePackages = [
      (config.boot.kernelPackages.v4l2loopback.overrideAttrs (old: {
        makeFlags = (old.makeFlags or [ ]) ++ [ "DEPMOD=true" ];
      }))
    ];
    kernel.sysctl."vm.max_map_count" = 2147483642;
    loader.systemd-boot.enable = lib.mkDefault true;
    loader.efi.canTouchEfiVariables = lib.mkDefault true;
    binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = "\\xff\\xff\\xff\\xff\\x00\\x00\\x00\\x00\\xff\\xff\\xff";
      magicOrExtension = "\\x7fELF....AI\\x02";
    };
  };
}
