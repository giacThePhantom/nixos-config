# river-reload: re-apply river settings, keybindings and rules after a
# rebuild, without restarting the session programs (see river/autostart.nix).
RIVER_RELOAD=1 "$HOME/.config/river/init"
notify-send -t 2000 "river" "Configuration reloaded"
