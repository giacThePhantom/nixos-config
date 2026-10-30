# RTX 3060 (Ampere): proprietary driver instead of nouveau.
# nouveau is blacklisted automatically by the nvidia module.
{
  flake.modules.nixos.nvidia =
    { config, pkgs, ... }:
    {
      hardware.graphics = {
        enable = true;
        enable32Bit = true; # Steam / Wine
        extraPackages = [ pkgs.nvidia-vaapi-driver ]; # VA-API -> NVDEC for Firefox/mpv
      };

      services.xserver.videoDrivers = [ "nvidia" ];
      hardware.nvidia = {
        open = true; # NVIDIA's open kernel module, recommended for Turing and newer
        modesetting.enable = true; # required for Wayland
        powerManagement.enable = true; # keep VRAM across suspend, avoids corruption on resume
        nvidiaSettings = false;
        package = config.boot.kernelPackages.nvidiaPackages.stable;
      };

      environment.sessionVariables = {
        LIBVA_DRIVER_NAME = "nvidia";
        NVD_BACKEND = "direct";
        GBM_BACKEND = "nvidia-drm";
        __GLX_VENDOR_LIBRARY_NAME = "nvidia";
      };

      environment.systemPackages = [ pkgs.nvtopPackages.nvidia ]; # GPU load, memory, processes

      # CUDA builds of packages (PyTorch, JAX... with cudaSupport in a
      # project) come prebuilt from the NixOS CUDA cache instead of compiling
      # for hours. Key from https://wiki.nixos.org/wiki/CUDA
      nix.settings = {
        extra-substituters = [ "https://cache.nixos-cuda.org" ];
        extra-trusted-public-keys = [
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];
      };
    };
}
