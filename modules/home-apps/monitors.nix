{ osConfig, ... }:
let
  monitorRules = osConfig.machine.monitorRules;
in
{
  services.grobi = {
    enable = monitorRules != [ ];
    settings.rules = monitorRules;
  };
}
