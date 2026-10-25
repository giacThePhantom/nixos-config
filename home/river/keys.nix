# Keybindings. Keep the table in README.md in sync when changing these.
# Names on PATH (term, focus-dir, tag, dash...) are the scripts in ../scripts.
{
  pkgs,
  lib,
  monitors,
  ...
}:
let
  spawn = cmd: "spawn '${cmd}'";
  layout = cmd: "send-layout-cmd rivercarro '${cmd}'";

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";

  # Super+1..9,0 for tags 1-10; each tag acts on the monitor that owns it
  tagKeys = lib.listToAttrs (
    lib.concatMap (
      i:
      let
        key = toString (lib.mod i 10);
        tag = action: spawn "tag ${action} ${toString (monitors.mask i)} ${(monitors.ownerOf i).name}";
      in
      [
        (lib.nameValuePair "Super ${key}" (tag "focus")) # again: back to previous tag
        (lib.nameValuePair "Super+Shift ${key}" (tag "send"))
        (lib.nameValuePair "Super+Alt ${key}" (tag "follow")) # send and follow
        (lib.nameValuePair "Super+Control ${key}" (tag "toggle"))
        (lib.nameValuePair "Super+Shift+Control ${key}" "toggle-view-tags ${toString (monitors.mask i)}")
      ]
    ) (lib.range 1 10)
  );

  # Dashboard panels (../dashboard): global key, and the letter that opens the
  # panel while the menu or another panel is shown
  panels = [
    {
      name = "calendar";
      key = "Super C";
      letter = "C";
    }
    {
      name = "media";
      key = "Super S";
      letter = "S";
    }
    {
      name = "system";
      key = "Super I";
      letter = "I";
    }
    {
      name = "power";
      key = "Super+Shift E";
      letter = "E";
    }
  ];
  panelKeys = lib.listToAttrs (
    map (p: lib.nameValuePair p.key (spawn "dash toggle ${p.name}")) panels
  );
  panelLetters = lib.listToAttrs (
    map (p: lib.nameValuePair "None ${p.letter}" (spawn "dash open ${p.name}")) panels
  );

  # Media keys also work on the lock screen
  volumeKeys = {
    "None XF86AudioRaiseVolume" = spawn "${wpctl} set-volume -l 1.0 @DEFAULT_AUDIO_SINK@ 5%+";
    "None XF86AudioLowerVolume" = spawn "${wpctl} set-volume @DEFAULT_AUDIO_SINK@ 5%-";
  };
  mediaKeys = {
    "None XF86AudioMute" = spawn "${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle";
    "None XF86AudioMicMute" = spawn "${wpctl} set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
    "None XF86AudioPlay" = spawn "${playerctl} play-pause";
    "None XF86AudioNext" = spawn "${playerctl} next";
    "None XF86AudioPrev" = spawn "${playerctl} previous";
  };
in
{
  wayland.windowManager.river.settings = {
    declare-mode = [
      "passthrough"
      "dashboard"
    ];

    map.normal =
      tagKeys
      // mediaKeys
      // panelKeys
      // {
        # Launchers
        "Super A" = spawn "dash toggle hub";
        "Super D" = "spawn fuzzel";
        "Super Return" = "spawn term";
        "Super grave" = "spawn scratchpad";
        "Super W" = "spawn firefox";
        "Super E" = spawn "term yazi";
        "Super B" = spawn "term btop";
        "Super+Shift M" = "spawn spotify";
        "Super P" = "spawn pwvucontrol";
        "Super V" = "spawn clipboard";
        "None Print" = spawn "screenshot region";
        "Super+Shift S" = spawn "screenshot region";
        "Shift Print" = spawn "screenshot full";
        "Super N" = spawn "makoctl dismiss";
        "Super+Shift N" = spawn "makoctl restore";
        "Super Escape" = spawn "loginctl lock-session";
        "Super+Shift R" = "spawn river-reload";

        # Windows: vim-style focus/move, crossing monitors at the edges
        "Super Q" = "close";
        "Super H" = spawn "focus-dir left";
        "Super J" = spawn "focus-dir down";
        "Super K" = spawn "focus-dir up";
        "Super L" = spawn "focus-dir right";
        "Super+Shift H" = spawn "move-dir left";
        "Super+Shift J" = spawn "move-dir down";
        "Super+Shift K" = spawn "move-dir up";
        "Super+Shift L" = spawn "move-dir right";
        "Super M" = "zoom"; # make master; on the master, swap in the next one
        "Super T" = "toggle-float";
        "Super F" = "toggle-fullscreen";
        # Floating windows: Alt moves, Alt+Shift resizes
        "Super+Alt H" = "move left 100";
        "Super+Alt J" = "move down 100";
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

        # Monitors
        "Super Period" = "focus-output next";
        "Super Comma" = "focus-output previous";
        "Super+Shift Period" = "send-to-output next";
        "Super+Shift Comma" = "send-to-output previous";

        # Previous tags / all tags of this monitor
        "Super Tab" = "focus-previous-tags";
        "Super+Shift Tab" = "set-focused-tags ${toString monitors.visibleTags}";

        # Passthrough mode: all keys go to the window (VMs, nested compositors)
        "Super F11" = "enter-mode passthrough";
      };
    map.passthrough."Super F11" = "enter-mode normal";
    # While a panel is open: its letter switches panel, Escape closes
    map.dashboard =
      panelKeys
      // panelLetters
      // {
        "None Escape" = spawn "dash close";
        "Super A" = spawn "dash toggle hub";
      };
    map.locked = mediaKeys;
    map."-repeat" = {
      normal = volumeKeys;
      locked = volumeKeys;
    };

    map-pointer.normal = {
      "Super BTN_LEFT" = "move-view";
      "Super BTN_RIGHT" = "resize-view";
      "Super BTN_MIDDLE" = "toggle-float";
    };
  };
}
