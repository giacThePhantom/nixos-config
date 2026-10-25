# Facts derived from settings.monitors, shared by river and the scripts.
{ lib, settings }:
let
  # Place monitors left to right: each starts where the previous one ends
  placed = lib.foldl (
    acc: m: acc ++ [ (m // { x = lib.foldl (sum: p: sum + p.width) 0 acc; }) ]
  ) [ ] settings.monitors;
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
