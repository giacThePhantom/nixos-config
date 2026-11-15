# What the river init does besides settings/keys/rules: on session start only,
# start the session's programs, the monitor layout first. They are plain
# children of river (no systemd user services) and exit with it. The
# Wayland environment reaches D-Bus/systemd, and river-session.target starts,
# at the end of the init (wayland.windowManager.river.systemd, settings.nix).
#
# river-reload re-runs the init with RIVER_RELOAD=1, which stops before the
# session-start part.
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.homeManager.river =
    {
      lib,
      pkgs,
      ...
    }:
    let
      c = colors;
      wallpaper = import ../theme/_wallpaper.nix { inherit pkgs colors fonts; };
      swaylock = "${pkgs.swaylock}/bin/swaylock -f";
      wlopm = "${pkgs.wlopm}/bin/wlopm";
    in
    {
      wayland.windowManager.river.extraConfig = ''
        # Lay the monitors out (again: layouts and scales may have changed).
        # Each keeps or gets one of its own tags (scripts/monitors.sh).
        monitors apply >/dev/null 2>&1 || true

        [ -n "$RIVER_RELOAD" ] && exit 0

        # ---- Session start only ----
        # Again whenever monitors are plugged in or out, and after a resume from
        # suspend, which re-creates them
        monitors watch &
        rivercarro -per-tag -inner-gaps 4 -outer-gaps 6 -main-ratio 0.55 &
        # The logo on the first monitor, the bare gradient on the others
        ${pkgs.swaybg}/bin/swaybg -o '*' -m fill -c '#${c.bg}' -i ${wallpaper.plain} \
          -o "$(monitors primary)" -m fill -c '#${c.bg}' -i ${wallpaper.branded} &
        # Night light: warmer colours from 20:30 to 07:00, easier on the eyes late
        # (-t night, -T day temperature in kelvin; -s/-S sunset/sunrise)
        ${pkgs.wlsunset}/bin/wlsunset -t 4000 -T 6500 -s 20:30 -S 07:00 &
        ${pkgs.mako}/bin/mako &
        foot --server &
        ${pkgs.wl-clipboard}/bin/wl-paste --watch ${pkgs.cliphist}/bin/cliphist store &
        ${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1 &
        # eww (dashboard, tag preview) up front, as river's child like the rest:
        # started on first use, the first panel or tag switch waits over a second
        ${pkgs.eww}/bin/eww daemon --no-daemonize &
        tag-preview & # card of all tags and their windows, on tag switches

        # Lock after 5 min, screens off after 10 min, lock before suspend
        ${pkgs.swayidle}/bin/swayidle -w \
          timeout 300 '${swaylock}' \
          timeout 600 '${wlopm} --off "*"' resume '${wlopm} --on "*"' \
          before-sleep '${swaylock}' \
          lock '${swaylock}' &
        # ...but not while sound plays: video calls (watching someone present)
        # and videos. Apps' own requests to keep the screen on go to
        # org.freedesktop.ScreenSaver, which nothing provides here.
        ${pkgs.wayland-pipewire-idle-inhibit}/bin/wayland-pipewire-idle-inhibit --quiet &
      '';
    };
}
