# Home row mods (kanata): hold a home row key for a modifier, tap it for its
# letter. Left hand A S D F = Super Alt Ctrl Shift, mirrored on J K L ; (the
# physical keys, whatever the layout). Every keyboard, also those plugged in
# later, and the text consoles too: kanata sits below the desktop.
#
# The hard part is not firing a modifier while typing, hence:
# - a key pressed right after another (typing) is always its letter;
# - a modifier needs a key of the other hand (S+K types "sk", D+L is Ctrl+L),
#   so same-hand rolls stay letters. Same-hand combos: hold past the timeout;
# - held alone past the timeout it is the modifier, so Super+drag works.
# The real modifier keys keep working as before.
{
  flake.modules.nixos.home-row-mods = {
    services.kanata = {
      enable = true;
      # No devices listed: kanata finds every keyboard, also hot-plugged ones
      keyboards.main = {
        # Unmapped keys must still pass through kanata, or it cannot see
        # what was pressed while a home row key waits
        extraDefCfg = ''
          process-unmapped-keys yes
          tap-hold-require-prior-idle 150
        '';
        config = ''
          (defhands
            (left  q w e r t a s d f g z x c v b)
            (right y u i o p h j k l ; n m , . /))

          (defsrc a s d f j k l ; caps)
          ;; ms a key waits for the other hand before it is its modifier anyway.
          ;; -release: the other key must also be released, so overlapping
          ;; keystrokes of fast typing stay letters. Keys of no hand (space,
          ;; digits...) wait for the timeout: Super+3 works holding A.
          (defvar hold 200)
          (deftemplate hrm (key mod)
            (tap-hold-opposite-hand-release $hold $key $mod (timeout hold)))

          (defalias
            a (t! hrm a lmet)
            s (t! hrm s lalt)
            d (t! hrm d lctl)
            f (t! hrm f lsft)
            j (t! hrm j rsft)
            k (t! hrm k rctl)
            l (t! hrm l ralt)
            ; (t! hrm ; rmet)
            cap-esc esc
            )

          (deflayer base @a @s @d @f @j @k @l @; @cap-esc)
        '';
      };
    };
  };
}
