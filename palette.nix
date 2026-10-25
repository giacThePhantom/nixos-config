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
    bgInput = "0c0a21"; # --bg-input (black 20%)
    bg = "0f0c29"; # --bg-primary
    bgCard = "1b1834"; # --bg-card (white 5%)
    bgTertiary = "24243e"; # --bg-tertiary
    bgSecondary = "302b63"; # --bg-secondary
    borderHeavy = "3f3d54"; # --border-glass-heavy (white 20%)

    # Text, dimmest to brightest
    textPlaceholder = "575569"; # --placeholder-color (white 30%)
    textMuted = "878694"; # --text-muted (white 50%)
    textMutedStrong = "9f9ea9"; # --text-muted-strong (white 60%)
    textSecondary = "c3c2ca"; # --text-secondary (white 75%)
    text = "f8fafc"; # --text-primary

    # Accent
    accent = "8b5cf6"; # --accent: focus, selection, borders
    accentHover = "7c3aed"; # --accent-hover
    accentLight = "a78bfa"; # --accent-light
    gradientStart = "667eea"; # --accent-gradient-start
    gradientEnd = "764ba2"; # --accent-gradient-end

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
