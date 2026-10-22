{ pkgs, ... }:
{
  # For steam start scripts
  systemd.tmpfiles.rules = [
    "L+ /sbin/ldconfig - - - - ${pkgs.glibc}/sbin/ldconfig"
  ];

}
