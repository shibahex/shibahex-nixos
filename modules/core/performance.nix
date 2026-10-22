# Latency/throughput tuning for plugged-in machines (not laptops on battery)
{ lib, config, ... }:
let
  cfg = config.modules.performance;
in
{
  options.modules.performance = {
    enable = lib.mkEnableOption "performance CPU governor, sched_ext and zram tuning";
    scheduler = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = "scx_lavd";
      description = "sched_ext scheduler to run (e.g. scx_lavd, scx_bpfland), or null for the kernel default.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        # Prevent CPU downclocking mid-playback (a common hidden xrun cause).
        powerManagement.cpuFreqGovernor = lib.mkDefault "performance";
      }
      (lib.mkIf (cfg.scheduler != null) {
        services.scx = {
          enable = true;
          scheduler = cfg.scheduler;
        };
      })
      # Swap to zram eagerly and skip readahead, since it's compressed RAM not disk
      (lib.mkIf config.zramSwap.enable {
        zramSwap.algorithm = lib.mkDefault "zstd";
        zramSwap.memoryPercent = lib.mkDefault 50;
        boot.kernel.sysctl = {
          "vm.swappiness" = lib.mkDefault 180;
          "vm.page-cluster" = lib.mkDefault 0;
          "vm.watermark_boost_factor" = lib.mkDefault 0;
        };
      })
    ]
  );
}
