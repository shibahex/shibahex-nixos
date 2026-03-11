{ config, lib, pkgs, modulesPath, ... }:

let
  mkApp = { name, bin, memHigh, memMax }: {
    wrapper = pkgs.writeShellScriptBin name ''
      exec systemd-run --user --scope \
        --slice=${name}.slice \
        -p MemoryHigh=${memHigh} \
        -p MemoryMax=${memMax} \
        -- ${bin} "$@"
    '';
    slice = lib.nameValuePair name {
      sliceConfig = {
        MemoryAccounting = true;
        MemoryHigh = memHigh;
        MemoryMax = memMax;
      };
    };
  };

  mkSlice = { name, memHigh, memMax }: lib.nameValuePair name {
    sliceConfig = {
      MemoryAccounting = true;
      MemoryHigh = memHigh;
      MemoryMax = memMax;
    };
  };

  apps = map mkApp [
    { name = "vesktop"; bin = "${pkgs.vesktop}/bin/vesktop"; memHigh = "600M"; memMax = "1G"; }
    { name = "spotify"; bin = "${pkgs.spotify}/bin/spotify"; memHigh = "200M"; memMax = "300M"; }
    { name = "steam"; bin = "${pkgs.steam}/bin/steam"; memHigh = "600M"; memMax = "1G"; }
  ];

  customSlices = map mkSlice [
    { name = "game"; memHigh = "infinity"; memMax = "infinity"; }
  ];

  appSlices = builtins.listToAttrs (map (app: app.slice) apps);
  extraSlices = builtins.listToAttrs customSlices;

in
{
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  environment.systemPackages = map (app: app.wrapper) apps;

  systemd.user.slices = appSlices // extraSlices;
}


