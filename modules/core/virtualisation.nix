{ pkgs
, lib
, config
, username
, ...
}:

let
  cfg = config.modules.virtualisation;
in
{
  options.modules.virtualisation = {
    enable = lib.mkEnableOption "virtualisation support";
    swtpm = lib.mkEnableOption "software TPM support";
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      virt-manager
      virt-viewer
      looking-glass-client
    ];

    virtualisation = {
      libvirtd = {
        enable = true;
        qemu = {
          swtpm.enable = cfg.swtpm;
        };
      };
    };

    users.users."qemu-libvirtd" = {
      extraGroups = [
        "render"
        "video"
        "kvm"
      ];
    };

    systemd.tmpfiles.rules = [
      "f /dev/shm/looking-glass 0660 ${username} kvm -"
    ];
  };
}
