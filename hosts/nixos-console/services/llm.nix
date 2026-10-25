{ pkgs, lib, ... }:

let
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

  modelsDir = "/var/lib/llama-swap";
in
{
  environment.systemPackages = [ llama-cpp-cuda ];

  systemd.services.llama-router = {
    description = "llama.cpp router server";
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # Previous config: full context + 2 models overflowed the 12GB GPU
      # (Xid 31 MMU fault on 2026-10-23). Explicit ctx/gpu-layers also
      # stopped --fit from adjusting them.
      ExecStart = ''
        ${lib.getExe' llama-cpp-cuda "llama-server"} \
          --host 127.0.0.1 \
          --port 11434 \
          --no-webui \
          --models-dir ${modelsDir} \
          --models-max 2 \
          --models-autoload \
          --ctx-size 0 \
          --n-gpu-layers -1
      '';

      # Leave ctx-size and n-gpu-layers unset so --fit can size them to VRAM.
      # ExecStart = ''
      #   ${lib.getExe' llama-cpp-cuda "llama-server"} \
      #     --host 0.0.0.0 \
      #     --port 11434 \
      #     --no-webui \
      #     --models-dir ${modelsDir} \
      #     --models-max 1 \
      #     --models-autoload \
      #     --fit on \
      #     --fit-ctx 16384 \
      #     --flash-attn on \
      #     --parallel 1
      # '';
      #
      StateDirectory = "llama";
      Restart = "always";
      RestartSec = "5";
      PrivateDevices = lib.mkForce false;
      LimitMEMLOCK = "infinity";

      Environment = [
        "CUDA_VISIBLE_DEVICES=0"
        "GGML_CUDA_ENABLE_UNIFIED_MEMORY=1"
        "LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib"
      ];
    };

    # Make sure the models directory exists
    preStart = ''
      mkdir -p ${modelsDir}
    '';
  };

  #embedding server for resolving web searches for oppen webui
  systemd.services.llama-embedding = {
    description = "llama.cpp embedding server";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      ExecStart = ''
        ${lib.getExe' llama-cpp-cuda "llama-server"} \
          --host 127.0.0.1 \
          --port 11435 \
          --no-webui \
          --model ${modelsDir}/embed/embeddinggemma-300M-Q8_0.gguf \
          --embedding \
          --pooling mean \
          --ctx-size 2048 \
          --n-gpu-layers -1
      '';
    };
  };
}
