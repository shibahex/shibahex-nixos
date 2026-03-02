{ host, pkgs, ... }:
let
  variables = import ../../hosts/${host}/variables.nix { pkgs = pkgs; };
  inherit (variables) monitorRules;
in
{
  services.grobi = {
    enable = monitorRules != [ ];
    rules = monitorRules;
  };
}
