# dnd: toggle do not disturb (Super+Ctrl+N), e.g. while sharing the screen.
# Notifications that arrive meanwhile are held (desktop.nix) and show when
# it's turned off, until dismissed (Super+N). There is no bar to show the
# state, so each switch says it with a short notification; switching on waits
# for that one to go before hiding everything.
if [[ $'\n'"$(makoctl mode)"$'\n' == *$'\n'do-not-disturb$'\n'* ]]; then
  makoctl mode -r do-not-disturb >/dev/null
  notify-send -a dnd -t 2000 -i notifications "Notifications on"
else
  notify-send -a dnd -t 1500 -i notifications-disabled "Do not disturb" \
    "Notifications wait until Super+Ctrl+N"
  sleep 1.6
  makoctl mode -a do-not-disturb >/dev/null
fi
