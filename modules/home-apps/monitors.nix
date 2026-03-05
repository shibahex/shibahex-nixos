{ host, pkgs, ... }:
let
  variables = import ../../hosts/${host}/variables.nix { pkgs = pkgs; };
  monitorRules = variables.monitorRules or [ ];

in
{
  services.grobi = {
    enable = monitorRules != [ ];
    rules = monitorRules;
  };
}
