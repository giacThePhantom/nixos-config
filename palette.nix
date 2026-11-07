# The system palette and fonts: with settings.nix, the file to edit to make
# this configuration yours. Every module (system and home) receives these as
# the `colors` and `fonts` arguments, so changing a value here re-themes
# everything: compositor, terminal, GTK, TTYs, login screen, apps.
#
# Colours are hex without '#', named after the CSS variables of the theme
# they come from. Translucent overlays (white/black at some %) are flattened
# over `bg`, since terminals and the compositor need opaque colours.
{
  colors = {
    # Backgrounds, darkest to lightest
    bgInput = "000119"; # --bg-input (black 20%)
    bg = "00011f"; # --bg-primary
    bgCard = "0d0e2a"; # --bg-card (white 5%)
    bgTertiary = "010339"; # --bg-tertiary
    bgSecondary = "04145c"; # --bg-secondary
    borderHeavy = "33344c"; # --border-glass-heavy (white 20%)

    # Text, dimmest to brightest
    textPlaceholder = "4d4d62"; # --placeholder-color (white 30%)
    textMuted = "80808f"; # --text-muted (white 50%)
    textMutedStrong = "9999a5"; # --text-muted-strong (white 60%)
    textSecondary = "bfc0c7"; # --text-secondary (white 75%)
    text = "f5f9ff"; # --text-primary

    # Accent
    accent = "2b6cf5"; # --accent: focus, selection, borders
    accentHover = "0050d8"; # --accent-hover
    accentLight = "66d4f5"; # --accent-light
    gradientStart = "0060f0"; # --accent-gradient-start
    gradientEnd = "8030f0"; # --accent-gradient-end
    illusSoft = "8a5cff"; # --illus-soft: the violet, for terminal magenta

    # Status: strong colour + lighter "-text" variant for text on dark bg
    danger = "ef4444";
    dangerText = "fca5a5";
    success = "10b981";
    successText = "6ee7b7";
    warning = "f59e0b";
    warningText = "fcd34d";
    info = "0dcaf0";
    infoText = "93c5fd";
    infoLight = "abefff"; # --logo-thelab
  };

  fonts = {
    mono = "JetBrains Mono";
    ui = "Inter";
    # Nerd Font icons only, used as fallback after the fonts above
    icons = "Symbols Nerd Font";
    iconsMono = "Symbols Nerd Font Mono"; # one cell wide, for the terminal
  };
}
