{
  pkgs,
  lib,
  config,
  ...
}:
{
  boot = {
    kernelPackages = lib.mkDefault (
      pkgs.linuxPackages_latest.extend (
        _final: prev: {
          # xpad-noone (pulled in by hardware.xone's mkDefault) hand-copies its .ko
          # instead of running Kbuild's modules_install, so it never gets a
          # modules_install-generated .ko.cer; NixOS's module aggregator expects one
          # from every external module and fails with "No such file or directory"
          # (nixpkgs#575192). Sign it ourselves like the proper fix.
          xpad-noone = prev.xpad-noone.overrideAttrs (old: {
            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ pkgs.kmodigest ];
            postInstall = (old.postInstall or "") + ''
              kmodigest $out/lib/modules/${prev.kernel.modDirVersion}/kernel/drivers/xpad-noone/xpad-noone.ko
            '';
          });
        }
      )
    );
    kernelModules = [ "v4l2loopback" ];
    extraModulePackages = [
      # Kernel's `dev` output now ships System.map, so kbuild's modules_install
      # runs depmod for out-of-tree modules too; v4l2loopback's own modules.alias
      # then collides with the kernel's when NixOS merges them (nixpkgs#576406).
      # DEPMOD=true no-ops that depmod call; the final aggregate depmod handles it.
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
