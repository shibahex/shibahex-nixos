{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [ pegasus-frontend ];
}
