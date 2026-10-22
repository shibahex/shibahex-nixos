{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.modules.yubikey;
in
{
  options.modules.yubikey = {
    enable = lib.mkEnableOption "YubiKey tools and smart card daemon";
    usbip = lib.mkOption {
      type = lib.types.nullOr (
        lib.types.enum [
          "server"
          "client"
        ]
      );
      default = null;
      description = "Share the key over USB/IP: \"server\" exports it (host), \"client\" attaches it (VM).";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        services.pcscd.enable = lib.mkDefault true;
        environment.systemPackages = [ pkgs.yubikey-manager ];
      }
      (lib.mkIf (cfg.usbip != null) {
        environment.systemPackages = [ pkgs.linuxPackages.usbip ];
        boot.kernelModules = [
          "usbip-core"
          (if cfg.usbip == "server" then "usbip-host" else "vhci-hcd")
        ];
      })
      # Exposes USB devices to the network; keep port 3240 closed unless needed
      (lib.mkIf (cfg.usbip == "server") {
        systemd.services.usbipd = {
          description = "USB/IP Daemon";
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${pkgs.linuxPackages.usbip}/bin/usbipd";
            Restart = "on-failure";
          };
        };
      })
    ]
  );
}
