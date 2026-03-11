{ config, lib, pkgs, modulesPath, ... }:

{
  zramSwap.enable = true;
  zramSwap.algorithm = "zstd";

  # ALL GUI APPS RAM MAX
  # systemd.user.slices."app" = {
  #   sliceConfig = {
  #     MemoryAccounting = true;
  #     MemoryHigh = "4G";
  #     MemoryMax = "6G";
  #   };
  # };
  #

  # Used for steam GUI
  systemd.user.slices."steam" = {
    sliceConfig = {
      MemoryAccounting = true;
      MemoryHigh = "600M";
      MemoryMax = "1G";
    };
  };

  systemd.user.slices."discord" = {
    sliceConfig = {
      MemoryAccounting = true;
      MemoryHigh = "600M";
      MemoryMax = "1G";
    };
  };

  systemd.user.slices."spotify" = {
    sliceConfig = {
      MemoryAccounting = true;
      MemoryHigh = "200M";
      MemoryMax = "300M";
    };
  };


  # In Steam, for each game, go to **Properties → Launch Options** and set:
  # ```
  # systemd-run --user --scope --slice=game.slice -- %command%
  systemd.user.slices."game" = {
    sliceConfig = {
      MemoryAccounting = true;
      MemoryHigh = "infinity";
      MemoryMax = "infinity";
    };
  };

}

