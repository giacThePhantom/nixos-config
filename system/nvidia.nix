# RTX 3060 (Ampere): proprietary driver instead of nouveau.
# nouveau is blacklisted automatically by the nvidia module.
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
}
