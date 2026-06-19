{ pkgs, ... }:
{
  # for looking glass and steam start scripts
  systemd.tmpfiles.rules = [
    "L+ /sbin/ldconfig - - - - ${pkgs.glibc}/sbin/ldconfig"
    "f /dev/shm/looking-glass 0660 shiba kvm -"
  ];

}
