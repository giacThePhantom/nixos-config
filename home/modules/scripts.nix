# Small helper commands, installed on PATH so river, the dashboard and the
# shell can all call them by name.
{ pkgs }:
let
  c = import ./palette.nix;
  eww = "${pkgs.eww}/bin/eww";
in
{
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
        ${eww} open dashboard
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
}
