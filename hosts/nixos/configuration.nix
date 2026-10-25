# Machine basics: boot, network, locale, sound, user. The desktop lives in
# ../../system, the user environment in ../../home.
{ pkgs, settings, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = settings.hostname;
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Rome";
  i18n.defaultLocale = "en_US.UTF-8";

  services.printing.enable = true;

  security.rtkit.enable = true; # realtime scheduling for PipeWire
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.${settings.user.name} = {
    isNormalUser = true;
    description = settings.user.fullName;
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
  };

  programs.firefox = {
    enable = true;
    # Text-to-speech pulls ~700 MB of speech-dispatcher and voices
    wrapperConfig.speechSynthesisSupport = false;
  };
  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
    auto-optimise-store = true; # hard-link identical files in the store
  };
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 14d";
  };

  # Version this machine was installed with; never change it (it is not the
  # NixOS version you run, see `man configuration.nix`).
  system.stateVersion = "26.05";
}
