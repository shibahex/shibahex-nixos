{ pkgs
, lib
, ...
}:
let
  # NOTE: ollama and lm-studio sucks just run llama-cpp yourself.
  # llama.cpp built with CUDA and OpenBLAS (for CPU fallback layers),
  # plus native CPU optimizations
  llama-cpp-cuda =
    (pkgs.llama-cpp.override {
      cudaSupport = true;
      blasSupport = true;
    }).overrideAttrs
      (old: {
        cmakeFlags = (old.cmakeFlags or [ ]) ++ [ "-DGGML_NATIVE=ON" ];
        preConfigure = ''
          export NIX_ENFORCE_NO_NATIVE=0
          ${old.preConfigure or ""}
        '';
      });
  llama-server = lib.getExe' llama-cpp-cuda "llama-server";
  modelsDir = "/var/lib/llama-swap";

  # Auto-discover all .gguf files in /var/lib/llama-swap and register them.
  # GGML_CUDA_ENABLE_UNIFIED_MEMORY=1 keeps model weights in RAM after first
  # load so reloads are RAM-speed instead of requiring full reinit.
  # --no-mmap ensures weights are actually read into RAM (not mapped from disk).
  modelEntries = lib.mapAttrs'
    (
      filename: _:
        lib.nameValuePair (lib.removeSuffix ".gguf" filename) {
          cmd = ''
            ${llama-server} \
              --port ''${PORT} \
              -m ${modelsDir}/${filename} \
              --no-webui \
              --ctx-size 32768 \
              --parallel 4 \
              --cont-batching \
              --no-mmap
          '';
        }
    )
    (lib.filterAttrs (n: t: t == "regular" && lib.hasSuffix ".gguf" n) (builtins.readDir modelsDir));
in
{
  # lact for GPU info on dashboard
  environment.systemPackages = with pkgs; [ lact ];
  systemd.packages = with pkgs; [ lact ];
  systemd.services.lact.enable = true;
  systemd.services.llama-swap.serviceConfig.SupplementaryGroups = [ "wheel" ];
  services.llama-swap = {
    enable = true;
    port = 11434;
    settings = {
      healthCheckTimeout = 60;
      models = modelEntries;
      performance = {
        disabled = false;
        every = "15s";
      };
    };
  };
  systemd.services.llama-swap.serviceConfig = {
    StateDirectory = "llama-swap";
    PrivateDevices = lib.mkForce false;
    LimitMEMLOCK = "infinity";
    Environment = [
      "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
      # Explicit GPU selection (redundant with one GPU)
      "CUDA_VISIBLE_DEVICES=0"
    ];
  };
}
