{ config, pkgs,... }: {
  boot.kernelModules = [ "cpufreq_stats" ];
  powerManagement.powertop.enable = false;
  environment.systemPackages = [ pkgs.powertop ];
  services = {
    thermald.enable = false;
    power-profiles-daemon.enable = false;

    # upower for batter stats
    upower.enable = true;

    tlp = {
      enable = true;
      settings = {
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 0;

        CPU_HWP_DYN_BOOST_ON_AC = 1;
        CPU_HWP_DYN_BOOST_ON_BAT = 0;

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
        CPU_ENERGY_PERF_POLICY_ON_BAT = "balance_power";

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "balanced";

        # Dual battery support
        START_CHARGE_THRESH_BAT0 = 60;
        STOP_CHARGE_THRESH_BAT0 = 90;
        START_CHARGE_THRESH_BAT1 = 60;
        STOP_CHARGE_THRESH_BAT1 = 90;
      };
    };

    # Optional: disable unless you really want it
    system76-scheduler.enable = true;
    #NOTE: GHOSTTY KILLS BATTERY LIFE
  };
}
