# System basics every machine gets: boot, network, locale, sound, the user,
# Nix itself.
{ config, ... }:
let
  inherit (config) settings;
in
{
  flake.modules.nixos.base =
    { pkgs, ... }:
    {
      boot.loader.systemd-boot.enable = true;
      boot.loader.efi.canTouchEfiVariables = true;
      boot.kernelPackages = pkgs.linuxPackages_latest;

      networking.hostName = settings.hostname;
      networking.networkmanager.enable = true;

      time.timeZone = "Europe/Rome";
      i18n.defaultLocale = "en_US.UTF-8";

      # settings.nix: keyboard; the desktop (river) and the text consoles,
      # including the login screen, use the same layout
      services.xserver.xkb = {
        inherit (settings.keyboard) layout variant options;
      };
      console.useXkbConfig = true;

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
    };
}
