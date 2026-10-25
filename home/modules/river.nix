{ pkgs, lib, ... }:
let
  c = import ./palette.nix;
  s = import ./scripts.nix { inherit pkgs; };

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  swaylock = "${pkgs.swaylock}/bin/swaylock -f";
  wlopm = "${pkgs.wlopm}/bin/wlopm";
  wallpaper = pkgs.nixos-artwork.wallpapers.nineish-catppuccin-mocha-alt.gnomeFilePath;

  # Tags 1-9: bitmask 2^(i-1)
  pow2 = n: lib.foldl (acc: _: acc * 2) 1 (lib.range 1 n);
  tagBinds = lib.listToAttrs (
    lib.concatMap (
      i:
      let
        k = toString i;
        t = toString (pow2 (i - 1));
      in
      [
        (lib.nameValuePair "Super ${k}" "set-focused-tags ${t}")
        (lib.nameValuePair "Super+Shift ${k}" "set-view-tags ${t}")
        (lib.nameValuePair "Super+Control ${k}" "toggle-focused-tags ${t}")
        (lib.nameValuePair "Super+Shift+Control ${k}" "toggle-view-tags ${t}")
      ]
    ) (lib.range 1 9)
  );

  # Usable on the lock screen too
  mediaBinds = {
    "None XF86AudioRaiseVolume" = "spawn '${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+'";
    "None XF86AudioLowerVolume" = "spawn '${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-'";
  };
  mediaOnce = {
    "None XF86AudioMute" = "spawn '${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle'";
    "None XF86AudioMicMute" = "spawn '${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle'";
    "None XF86AudioPlay" = "spawn '${playerctl} play-pause'";
    "None XF86AudioNext" = "spawn '${playerctl} next'";
    "None XF86AudioPrev" = "spawn '${playerctl} previous'";
  };
in
{
  home.packages = builtins.attrValues s ++ [
    pkgs.eww
    pkgs.river-tag-overlay
  ];

  wayland.windowManager.river = {
    enable = true;
    package = null; # installed system-wide by programs.river-classic
    xwayland.enable = false; # likewise
    # No systemd user session: river's init starts everything itself.
    systemd.enable = false;

    extraSessionVariables = {
      XDG_CURRENT_DESKTOP = "river";
      XDG_SESSION_DESKTOP = "river";
    };

    settings = {
      background-color = "0x${c.crust}";
      border-width = 2;
      border-color-focused = "0x${c.mauve}";
      border-color-unfocused = "0x${c.surface0}";
      border-color-urgent = "0x${c.red}";

      declare-mode = [ "passthrough" "dashboard" ];
      default-layout = "rivertile";
      focus-follows-cursor = "normal";
      set-cursor-warp = "on-focus-change";
      hide-cursor.when-typing = "enabled";
      set-repeat = "50 300";
      xcursor-theme = "Bibata-Modern-Classic 24";

      map = {
        normal = tagBinds // mediaOnce // {
          # Launchers
          "Super A" = "spawn 'dash toggle'";
          "Super D" = "spawn fuzzel";
          "Super Return" = "spawn term";
          "Super W" = "spawn firefox";
          "Super E" = "spawn 'term yazi'";
          "Super B" = "spawn 'term btop'";
          "Super M" = "spawn spotify";
          "Super P" = "spawn pwvucontrol";
          "Super V" = "spawn clipboard";
          "None Print" = "spawn 'screenshot region'";
          "Super+Shift S" = "spawn 'screenshot region'";
          "Shift Print" = "spawn 'screenshot full'";
          "Super N" = "spawn 'makoctl dismiss'";
          "Super+Shift N" = "spawn 'makoctl restore'";
          "Super Escape" = "spawn 'loginctl lock-session'";
          "Super+Shift E" = "spawn powermenu";

          # Windows
          "Super Q" = "close";
          "Super J" = "focus-view next";
          "Super K" = "focus-view previous";
          "Super+Shift J" = "swap next";
          "Super+Shift K" = "swap previous";
          "Super+Shift Return" = "zoom";
          "Super Space" = "toggle-float";
          "Super F" = "toggle-fullscreen";
          "Super+Alt H" = "move left 100";
          "Super+Alt J" = "move down 100";
          "Super+Alt K" = "move up 100";
          "Super+Alt L" = "move right 100";

          # Layout (rivertile)
          "Super H" = "send-layout-cmd rivertile 'main-ratio -0.05'";
          "Super L" = "send-layout-cmd rivertile 'main-ratio +0.05'";
          "Super+Shift H" = "send-layout-cmd rivertile 'main-count +1'";
          "Super+Shift L" = "send-layout-cmd rivertile 'main-count -1'";
          "Super Up" = "send-layout-cmd rivertile 'main-location top'";
          "Super Right" = "send-layout-cmd rivertile 'main-location right'";
          "Super Down" = "send-layout-cmd rivertile 'main-location bottom'";
          "Super Left" = "send-layout-cmd rivertile 'main-location left'";

          # Outputs
          "Super Period" = "focus-output next";
          "Super Comma" = "focus-output previous";
          "Super+Shift Period" = "send-to-output next";
          "Super+Shift Comma" = "send-to-output previous";

          # All tags / previous tags
          "Super 0" = "set-focused-tags 4294967295";
          "Super+Shift 0" = "set-view-tags 4294967295";
          "Super Tab" = "focus-previous-tags";

          # Passthrough mode (for VMs / nested compositors)
          "Super F11" = "enter-mode passthrough";
        };
        dashboard = {
          "None Escape" = "spawn 'dash close'";
          "Super A" = "spawn 'dash close'";
        };
        locked = mediaOnce;
        passthrough."Super F11" = "enter-mode normal";
        "-repeat" = {
          normal = mediaBinds;
          locked = mediaBinds;
        };
      };

      map-pointer.normal = {
        "Super BTN_LEFT" = "move-view";
        "Super BTN_RIGHT" = "resize-view";
        "Super BTN_MIDDLE" = "toggle-float";
      };
    };

    extraConfig = ''
      # Server-side decorations everywhere: borders instead of fat client titlebars
      riverctl rule-add -app-id '*' ssd
      riverctl rule-add -app-id 'com.saivert.pwvucontrol' float
      riverctl rule-add -title 'Picture-in-Picture' float

      # Portals and other D-Bus-activated services need the Wayland env
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE

      # Session programs: plain children of river, they exit with it
      rivertile -view-padding 4 -outer-padding 6 -main-ratio 0.55 &
      ${pkgs.swaybg}/bin/swaybg -m fill -c '#${c.base}' -i ${wallpaper} &
      ${pkgs.mako}/bin/mako &
      foot --server &
      ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store &
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      river-tag-overlay --border-width 2 --tag-amount 9 --timeout 400 \
        --background-colour 0x${c.base}ee --border-colour 0x${c.surface1}ff \
        --square-active-background-colour 0x${c.mauve}ff --square-active-border-colour 0x${c.mauve}ff \
        --square-inactive-background-colour 0x${c.surface0}ff --square-inactive-border-colour 0x${c.surface1}ff \
        --square-urgent-background-colour 0x${c.red}ff --square-urgent-border-colour 0x${c.red}ff \
        --square-inactive-occupied-colour 0x${c.text}ff --square-active-occupied-colour 0x${c.crust}ff &
      ${pkgs.eww}/bin/eww daemon

      # Lock after 5 min, screens off after 10 min, lock before suspend
      ${pkgs.swayidle}/bin/swayidle -w \
        timeout 300 '${swaylock}' \
        timeout 600 '${wlopm} --off "*"' resume '${wlopm} --on "*"' \
        before-sleep '${swaylock}' \
        lock '${swaylock}' &
    '';
  };
}
