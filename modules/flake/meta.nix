# Values every module can read from the flake-parts `config`: who you are and
# how monitors are laid out (../../settings.nix), colours and fonts
# (../../palette.nix), and tag facts shared by river and the scripts. Which
# monitor owns which tag is decided at runtime, as monitors come and go
# (scripts/monitors.sh).
{ lib, config, ... }:
let
  palette = import ../../palette.nix;
  value =
    description: default:
    lib.mkOption {
      type = lib.types.raw;
      inherit description default;
    };
in
{
  options = {
    settings = value "User, hostname, keyboard and monitor layouts" (import ../../settings.nix);
    colors = value "Palette colours, hex without '#'" palette.colors;
    fonts = value "Font family names" palette.fonts;
    monitors = value "Tag bitmasks" rec {
      # Tag bitmask: tag i is bit i-1
      mask = tag: lib.foldl (acc: _: acc * 2) 1 (lib.range 2 tag);

      # Hidden tags: the scratchpad terminal lives on 21, the mirror of the
      # laptop screen (mirror layout) on 22. "All tags" excludes both.
      scratchTag = mask 21;
      mirrorTag = mask 22;
      visibleTags = mask 33 - 1 - scratchTag - mirrorTag;
    };
  };
}
