{ lib, ... }:
let
  monitor = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    default = null;
  };
in
{
  options.machine = {
    timeZone = lib.mkOption {
      type = lib.types.str;
      default = "America/New_York";
    };
    shell = lib.mkOption {
      type = lib.types.enum [
        "zsh"
        "nushell"
      ];
      default = "zsh";
    };
    monitors = {
      main = monitor;
      right = monitor;
      left = monitor;
    };
    monitorRules = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      default = [ ];
      description = "grobi rules for X11 monitor layouts.";
    };
  };
}
