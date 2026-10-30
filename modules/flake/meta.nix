# Values every module can read from the flake-parts `config`: who you are and
# your monitors (../../settings.nix), colours and fonts (../../palette.nix),
# and facts derived from the monitors, shared by river and the scripts.
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
    settings = value "User, hostname and monitors" (import ../../settings.nix);
    colors = value "Palette colours, hex without '#'" palette.colors;
    fonts = value "Font family names" palette.fonts;
    monitors = value "Monitor layout derived from settings.monitors" (
      let
        # Place monitors left to right: each starts where the previous one ends
        placed = lib.foldl (
          acc: m: acc ++ [ (m // { x = lib.foldl (sum: p: sum + p.width) 0 acc; }) ]
        ) [ ] config.settings.monitors;
      in
      rec {
        all = placed;
        primary = lib.findFirst (m: m.primary or false) (lib.last placed) placed;

        # Monitor that owns tag `tag` (1-10)
        ownerOf = tag: lib.findFirst (m: lib.elem tag m.tags) primary placed;

        # Tag bitmask: tag i is bit i-1
        mask = tag: lib.foldl (acc: _: acc * 2) 1 (lib.range 2 tag);

        # The scratchpad terminal lives on hidden tag 21; "all tags" excludes it
        scratchTag = mask 21;
        visibleTags = mask 33 - 1 - scratchTag;
      }
    );
  };
}
