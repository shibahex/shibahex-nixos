{ osConfig, ... }:
let
  monitorRules = osConfig.machine.monitorRules;
in
{
  services.grobi = {
    enable = monitorRules != [ ];
    rules = monitorRules;
  };
}
