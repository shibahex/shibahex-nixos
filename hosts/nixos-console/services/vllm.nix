{ pkgs, ... }:
{
  services.vllm = {
    enable = true;
    models = [
      "nvidia/Qwen2.5-35B-A3B-NVFP4"
      "openbmb/MiniCPM5-1B"
    ];
    # Additional config for tensor parallelism, quantization, etc.
  };
}
