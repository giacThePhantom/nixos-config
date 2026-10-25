# System palette, hex without '#'. Imported by every module so the whole
# desktop shares it: change it here and everything follows.
#
# Derived from the "dark" web theme (--var names in comments). Translucent
# white/black values are flattened over --bg-primary into solid colours, since
# terminals and the compositor need opaque hex. Key names are kept from the
# previous palette so modules don't care which theme is active.
{
  # Backgrounds
  base = "0f0c29"; # --bg-primary
  mantle = "1b1834"; # --bg-card (white 5%)
  crust = "0c0a21"; # --bg-input (black 20%)
  surface0 = "24243e"; # --bg-tertiary
  surface1 = "302b63"; # --bg-secondary
  surface2 = "3f3d54"; # --border-glass-heavy (white 20%)

  # Text
  overlay0 = "575569"; # --placeholder-color (white 30%)
  overlay1 = "878694"; # --text-muted (white 50%)
  subtext0 = "9f9ea9"; # --text-muted-strong (white 60%)
  subtext1 = "c3c2ca"; # --text-secondary (white 75%)
  text = "f8fafc"; # --text-primary

  # Accents
  mauve = "8b5cf6"; # --accent (focus, selection, borders)
  accentHover = "7c3aed"; # --accent-hover
  pink = "a78bfa"; # --accent-light
  lavender = "667eea"; # --accent-gradient-start
  gradEnd = "764ba2"; # --accent-gradient-end
  rosewater = "a78bfa"; # --accent-light

  # Status
  red = "ef4444"; # --danger
  maroon = "fca5a5"; # --danger-text
  green = "10b981"; # --success
  teal = "6ee7b7"; # --success-text
  peach = "f59e0b"; # --warning
  yellow = "fcd34d"; # --warning-text
  sapphire = "0dcaf0"; # --info
  blue = "93c5fd"; # --info-text
  sky = "abefff"; # --logo-thelab

  font = "JetBrainsMono Nerd Font";
  uiFont = "Inter";
}
