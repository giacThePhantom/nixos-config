# What the river init does besides settings/keys/rules: lay out monitors and,
# on session start only, start the session's programs. They are plain
# children of river (no systemd user services) and exit with it.
#
# river-reload re-runs the init with RIVER_RELOAD=1, which stops before the
# session-start part.
{
  lib,
  pkgs,
  colors,
  monitors,
  ...
}:
let
  c = colors;
  wallpaper = import ../theme/wallpaper.nix { inherit pkgs colors; };
  swaylock = "${pkgs.swaylock}/bin/swaylock -f";
  wlopm = "${pkgs.wlopm}/bin/wlopm";

  # One call per monitor, so an unplugged one doesn't block the others
  layoutMonitors = lib.concatMapStringsSep "\n" (
    m:
    "${pkgs.wlr-randr}/bin/wlr-randr --output ${m.name} --preferred --pos ${toString m.x},0 2>/dev/null"
  ) monitors.all;

  # Each monitor starts on its first tag; focus ends on the primary
  startTags = lib.concatMapStringsSep "\n" (m: ''
    riverctl focus-output ${m.name}
    riverctl set-focused-tags ${toString (monitors.mask (lib.head m.tags))}
  '') (lib.filter (m: m != monitors.primary) monitors.all ++ [ monitors.primary ]);
in
{
  wayland.windowManager.river.extraConfig = ''
    ${layoutMonitors}

    [ -n "$RIVER_RELOAD" ] && exit 0

    # ---- Session start only ----
    ${startTags}
    # Portals and other D-Bus-activated services need the Wayland env
    ${pkgs.dbus}/bin/dbus-update-activation-environment --systemd \
      WAYLAND_DISPLAY XDG_CURRENT_DESKTOP XDG_SESSION_DESKTOP NIXOS_OZONE_WL XCURSOR_THEME XCURSOR_SIZE

    rivercarro -per-tag -inner-gaps 4 -outer-gaps 6 -main-ratio 0.55 &
    ${pkgs.swaybg}/bin/swaybg -m fill -c '#${c.bg}' -i ${wallpaper} &
    ${pkgs.mako}/bin/mako &
    foot --server &
    ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store &
    ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
    river-tag-overlay --border-width 2 --tag-amount 10 --timeout 400 \
      --background-colour 0x${c.bg}ee --border-colour 0x${c.bgSecondary}ff \
      --square-active-background-colour 0x${c.accent}ff --square-active-border-colour 0x${c.accent}ff \
      --square-inactive-background-colour 0x${c.bgTertiary}ff --square-inactive-border-colour 0x${c.bgSecondary}ff \
      --square-urgent-background-colour 0x${c.danger}ff --square-urgent-border-colour 0x${c.danger}ff \
      --square-inactive-occupied-colour 0x${c.text}ff --square-active-occupied-colour 0x${c.bgInput}ff &

    # Lock after 5 min, screens off after 10 min, lock before suspend
    ${pkgs.swayidle}/bin/swayidle -w \
      timeout 300 '${swaylock}' \
      timeout 600 '${wlopm} --off "*"' resume '${wlopm} --on "*"' \
      before-sleep '${swaylock}' \
      lock '${swaylock}' &
  '';
}
