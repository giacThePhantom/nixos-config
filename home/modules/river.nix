{ pkgs, lib, ... }:
let
  c = import ./palette.nix;

  # Tag bitmasks: tag i is 2^(i-1); the scratchpad lives on hidden tag 21
  pow2 = n: lib.foldl (acc: _: acc * 2) 1 (lib.range 1 n);
  allTags = pow2 32 - 1;
  scratchTag = pow2 20;
  visibleTags = toString (allTags - scratchTag);

  # Tags 1-5 live on the secondary monitor, 6-10 (key 0) on the primary
  secondary = "DP-1";
  primary = "HDMI-A-1";
  tagOutput = i: if i <= 5 then secondary else primary;

  s = import ./scripts.nix { inherit pkgs scratchTag; };

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  wlr-randr = "${pkgs.wlr-randr}/bin/wlr-randr";
  swaylock = "${pkgs.swaylock}/bin/swaylock -f";
  wlopm = "${pkgs.wlopm}/bin/wlopm";
  wallpaper = import ./wallpaper.nix { inherit pkgs; };

  tagBinds = lib.listToAttrs (
    lib.concatMap (
      i:
      let
        k = toString (lib.mod i 10); # tag 10 is on key 0
        t = toString (pow2 (i - 1));
        tag = action: "spawn 'tag ${action} ${t} ${tagOutput i}'";
      in
      [
        # Jump to the tag's monitor; pressing the current tag again goes back
        (lib.nameValuePair "Super ${k}" (tag "focus"))
        (lib.nameValuePair "Super+Shift ${k}" (tag "send"))
        # Move the window to the tag and follow it
        (lib.nameValuePair "Super+Alt ${k}" (tag "follow"))
        (lib.nameValuePair "Super+Control ${k}" (tag "toggle"))
        (lib.nameValuePair "Super+Shift+Control ${k}" "toggle-view-tags ${t}")
      ]
    ) (lib.range 1 10)
  );

  layout = cmd: "send-layout-cmd rivercarro '${cmd}'";

  # "!" steps count when they succeed: swap fails when there's nothing to
  # swap with (see system/patches); the send step counts when focus reaches
  # the other monitor, i.e. only if there is one
  moveDir =
    dir: last:
    "spawn 'river-try \"!swap ${dir}\" \"send-to-output -current-tags ${dir}; focus-output ${dir}\""
    + lib.optionalString (last != "") " \"!${last}\""
    + "'";

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

  # [ app-id title ]: windows that should start floating
  floatRules = [
    [ "com.saivert.pwvucontrol" "*" ]
    [ "*" "Picture-in-Picture" ]
    [ "xdg-desktop-portal-gtk" "*" ] # file pickers
    [ "polkit-gnome-authentication-agent-1" "*" ]
    [ "pinentry-*" "*" ]
    [ "nm-connection-editor" "*" ]
    [ "blueman-manager" "*" ]
    [ "zenity" "*" ]
    [ "firefox" "File Upload" ]
    [ "firefox" "Library" ]
    [ "firefox" "About Mozilla Firefox" ]
    [ "steam" "Friends List" ]
    [ "steam" "Steam Settings" ]
  ];
in
{
  home.packages = builtins.attrValues s ++ [
    pkgs.eww
    pkgs.river-tag-overlay
    pkgs.rivercarro
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
      default-layout = "rivercarro";
      focus-follows-cursor = "normal";
      set-cursor-warp = "on-focus-change";
      hide-cursor.when-typing = "enabled";
      set-repeat = "50 300";
      # New windows never land on the scratchpad tag
      spawn-tagmask = visibleTags;
      xcursor-theme = "Bibata-Modern-Classic 24";

      map = {
        normal = tagBinds // mediaOnce // {
          # Launchers
          "Super A" = "spawn 'dash toggle'";
          "Super D" = "spawn fuzzel";
          "Super Return" = "spawn term";
          "Super grave" = "spawn scratchpad";
          "Super W" = "spawn firefox";
          "Super E" = "spawn 'term yazi'";
          "Super B" = "spawn 'term btop'";
          "Super+Shift M" = "spawn spotify";
          "Super P" = "spawn pwvucontrol";
          "Super V" = "spawn clipboard";
          "None Print" = "spawn 'screenshot region'";
          "Super+Shift S" = "spawn 'screenshot region'";
          "Shift Print" = "spawn 'screenshot full'";
          "Super N" = "spawn 'makoctl dismiss'";
          "Super+Shift N" = "spawn 'makoctl restore'";
          "Super Escape" = "spawn 'loginctl lock-session'";
          "Super+Shift E" = "spawn powermenu";
          "Super+Shift R" = "spawn river-reload";

          # Windows
          "Super Q" = "close";
          # Vim-style focus: the closest window in that direction, else the
          # monitor in that direction. J/K finally cycle the stack, so they
          # also work in monocle.
          "Super H" = "spawn 'river-try \"focus-view left\" \"focus-output left\"'";
          "Super J" = "spawn 'river-try \"focus-view down\" \"focus-output down\" \"focus-view next\"'";
          "Super K" = "spawn 'river-try \"focus-view up\" \"focus-output up\" \"focus-view previous\"'";
          "Super L" = "spawn 'river-try \"focus-view right\" \"focus-output right\"'";
          # Swap with the window in that direction, else move it to the
          # monitor in that direction (onto its visible tags) and follow it
          "Super+Shift H" = moveDir "left" "";
          "Super+Shift J" = moveDir "down" "swap next";
          "Super+Shift K" = moveDir "up" "swap previous";
          "Super+Shift L" = moveDir "right" "";
          # Make the focused window master; on the master, swap in the next one
          "Super M" = "zoom";
          "Super T" = "toggle-float";
          "Super F" = "toggle-fullscreen";
          # Floating windows: Alt moves, Alt+Shift resizes
          "Super+Alt H" = "move left 100";
          "Super+Alt J" = "move down 101";
          "Super+Alt K" = "move up 100";
          "Super+Alt L" = "move right 100";
          "Super+Alt+Shift H" = "resize horizontal -100";
          "Super+Alt+Shift J" = "resize vertical 100";
          "Super+Alt+Shift K" = "resize vertical -100";
          "Super+Alt+Shift L" = "resize horizontal 100";

          # Layout (rivercarro, remembered per tag)
          "Super+Control H" = layout "main-ratio -0.05";
          "Super+Control L" = layout "main-ratio +0.05";
          "Super+Control K" = layout "main-count +1";
          "Super+Control J" = layout "main-count -1";
          "Super O" = layout "main-location-cycle left,monocle";
          "Super Up" = layout "main-location top";
          "Super Right" = layout "main-location right";
          "Super Down" = layout "main-location bottom";
          "Super Left" = layout "main-location left";
          "Super Equal" = layout "gaps +2";
          "Super Minus" = layout "gaps -2";

          # Outputs
          "Super Period" = "focus-output next";
          "Super Comma" = "focus-output previous";
          "Super+Shift Period" = "send-to-output next";
          "Super+Shift Comma" = "send-to-output previous";

          # Previous tags / all tags of this monitor
          "Super Tab" = "focus-previous-tags";
          "Super+Shift Tab" = "set-focused-tags ${visibleTags}";

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

    # Everything above and the rules below are safe to re-run: `river-reload`
    # (Super+Shift+R) runs this file again with RIVER_RELOAD=1.
    extraConfig = ''
      # Server-side decorations everywhere: borders instead of fat client titlebars
      riverctl rule-add -app-id '*' ssd
      ${lib.concatMapStringsSep "\n" (
        r: "riverctl rule-add -app-id '${builtins.elemAt r 0}' -title '${builtins.elemAt r 1}' float"
      ) floatRules}

      # Scratchpad terminal (Super+`)
      riverctl rule-add -app-id scratchpad float
      riverctl rule-add -app-id scratchpad tags ${toString scratchTag}
      riverctl rule-add -app-id scratchpad dimensions 1400 800
      riverctl rule-add -app-id scratchpad position 260 140 # centred on 1920x1080

      # Monitors: 24" (DP-1) on the left, 27" (HDMI-A-1) on the right.
      # One call per output so an unplugged screen doesn't block the other.
      ${wlr-randr} --output ${secondary} --preferred --pos 0,0 2>/dev/null
      ${wlr-randr} --output ${primary} --preferred --pos 1920,0 2>/dev/null

      [ -n "$RIVER_RELOAD" ] && exit 0

      # ---- Session start only ----
      # Each monitor starts on its first tag; focus ends on the primary
      riverctl focus-output ${secondary}
      riverctl set-focused-tags 1
      riverctl focus-output ${primary}
      riverctl set-focused-tags ${toString (pow2 5)}

      # Portals and other D-Bus-activated services need the Wayland env
      ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
        WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE

      # Session programs: plain children of river, they exit with it
      rivercarro -per-tag -inner-gaps 4 -outer-gaps 6 -main-ratio 0.55 &
      ${pkgs.swaybg}/bin/swaybg -m fill -c '#${c.base}' -i ${wallpaper} &
      ${pkgs.mako}/bin/mako &
      foot --server &
      ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store &
      ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
      river-tag-overlay --border-width 2 --tag-amount 10 --timeout 400 \
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
