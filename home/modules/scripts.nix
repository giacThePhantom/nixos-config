# Small helper commands, installed on PATH so river, the dashboard and the
# shell can all call them by name.
{ pkgs, scratchTag }:
let
  c = import ./palette.nix;
  eww = "${pkgs.eww}/bin/eww";
in
rec {
  # river-output, river-try (see ../pkgs/river-tools)
  river-tools = pkgs.callPackage ../pkgs/river-tools { };

  # tag focus|send|follow|toggle TAGMASK OUTPUT: tags belong to a fixed
  # monitor, so act on that monitor (moving the window there if needed).
  tag = pkgs.writeShellScriptBin "tag" ''
    action=$1 tags=$2 out=$3
    cur=$(${river-tools}/bin/river-output)
    case $action in
      focus)
        riverctl focus-output "$out"
        exec ${pkgs.river-bnf}/bin/river-bnf "$tags" ;;
      toggle)
        riverctl focus-output "$out"
        riverctl toggle-focused-tags "$tags" ;;
      send|follow)
        if [ "$cur" != "$out" ]; then
          # Retag while the tag is briefly shown here, so the window stays
          # focused; send-to-output then keeps its tags.
          riverctl toggle-focused-tags "$tags"
          riverctl set-view-tags "$tags"
          riverctl send-to-output "$out"
          riverctl toggle-focused-tags "$tags"
        else
          riverctl set-view-tags "$tags"
        fi
        if [ "$action" = follow ]; then
          riverctl focus-output "$out"
          riverctl set-focused-tags "$tags"
        fi ;;
    esac
  '';

  # footclient attaches to the foot server (instant startup); fall back to a
  # standalone foot if the server isn't running.
  term = pkgs.writeShellScriptBin "term" ''footclient "$@" || exec foot "$@"'';

  screenshot = pkgs.writeShellScriptBin "screenshot" ''
    dir="$HOME/Pictures/Screenshots"; mkdir -p "$dir"
    file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"
    if [ "$1" = region ]; then
      geom="$(${pkgs.slurp}/bin/slurp -d -b ${c.base}88 -c ${c.mauve}ff)" || exit 0
      ${pkgs.grim}/bin/grim -g "$geom" "$file"
    else
      ${pkgs.grim}/bin/grim "$file"
    fi
    ${pkgs.wl-clipboard}/bin/wl-copy < "$file"
    ${pkgs.libnotify}/bin/notify-send -i "$file" "Screenshot" "Copied and saved to $file"
  '';

  clipboard = pkgs.writeShellScriptBin "clipboard" ''
    ${pkgs.cliphist}/bin/cliphist list \
      | fuzzel --dmenu --prompt "󰅌  " \
      | ${pkgs.cliphist}/bin/cliphist decode \
      | ${pkgs.wl-clipboard}/bin/wl-copy
  '';

  powermenu = pkgs.writeShellScriptBin "powermenu" ''
    choice="$(printf '%s\n' "󰌾  Lock" "󰤄  Suspend" "󰍃  Logout" "󰜉  Reboot" "󰐥  Shutdown" \
      | fuzzel --dmenu --prompt "" --lines 5 --width 18)"
    case "$choice" in
      *Lock) loginctl lock-session ;;
      *Suspend) systemctl suspend ;;
      *Logout) riverctl exit ;;
      *Reboot) systemctl reboot ;;
      *Shutdown) systemctl poweroff ;;
    esac
  '';

  # Dashboard toggle. While open, river is in the "dashboard" mode so Escape
  # closes it, and the dashboard's polls run only while dash_open is true.
  dash = pkgs.writeShellScriptBin "dash" ''
    case "$1" in
      open)
        ${eww} update dash_open=true
        # Main monitor; fall back to the first one if it's unplugged
        ${eww} open dashboard --screen HDMI-A-1 || ${eww} open dashboard --screen 0
        riverctl enter-mode dashboard ;;
      close)
        ${eww} close dashboard
        ${eww} update dash_open=false
        riverctl enter-mode normal ;;
      *)
        if ${eww} active-windows | grep -q dashboard; then exec "$0" close; else exec "$0" open; fi ;;
    esac
  '';

  # Close the dashboard, then launch the command as a child of river
  dash-run = pkgs.writeShellScriptBin "dash-run" ''
    dash close
    riverctl spawn "$*"
  '';

  # Show/hide the scratchpad terminal. It lives on a hidden tag (see
  # river.nix); started on first use.
  scratchpad = pkgs.writeShellScriptBin "scratchpad" ''
    if ! ${pkgs.lswt}/bin/lswt -j \
      | ${pkgs.jq}/bin/jq -e 'any(.toplevels[]; ."app-id" == "scratchpad")' >/dev/null; then
      riverctl spawn 'footclient --app-id scratchpad || foot --app-id scratchpad'
    fi
    riverctl toggle-focused-tags ${toString scratchTag}
  '';

  # Re-apply river settings, keybindings and rules after `rebuild`, without
  # restarting the session programs.
  river-reload = pkgs.writeShellScriptBin "river-reload" ''
    RIVER_RELOAD=1 "$HOME/.config/river/init" \
      && ${pkgs.libnotify}/bin/notify-send -t 2000 "river" "Configuration reloaded"
  '';
}
