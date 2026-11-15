# Small river helpers that nothing in nixpkgs covers:
#   river-output  print the focused output's name
#   river-try     run river commands until one changes focus
#   river-tags-watch  print each change of an output's focused tags
#   river-awake   keep the screen awake until killed (wlinhibit and the like
#                 use a surface river ignores: it wants one that is shown)
#   river-outputs-watch  print a line whenever monitors are plugged or unplugged
{
  lib,
  stdenv,
  pkg-config,
  wayland,
  wayland-scanner,
  wayland-protocols,
  wlr-protocols,
  river-classic,
}:
stdenv.mkDerivation {
  pname = "river-tools";
  version = "0.5";
  # Only the sources, so editing this file doesn't rebuild the tools
  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.fileFilter (f: f.hasExt "c") ./.;
  };

  nativeBuildInputs = [
    pkg-config
    wayland-scanner
  ];
  buildInputs = [ wayland ];

  buildPhase = ''
    protocol() {
      wayland-scanner client-header "$1/$2.xml" "$2-client-protocol.h"
      wayland-scanner private-code "$1/$2.xml" "$2-protocol.c"
    }
    for p in status control; do
      protocol ${river-classic.src}/protocol river-$p-unstable-v1
    done
    protocol ${wayland-protocols}/share/wayland-protocols/unstable/idle-inhibit idle-inhibit-unstable-v1
    protocol ${wayland-protocols}/share/wayland-protocols/stable/xdg-shell xdg-shell
    protocol ${wlr-protocols}/share/wlr-protocols/unstable wlr-layer-shell-unstable-v1
    protocol ${wlr-protocols}/share/wlr-protocols/unstable wlr-output-management-unstable-v1
    flags="-O2 -Wall $(pkg-config --cflags --libs wayland-client)"
    $CC -o river-output river-output.c river-status-unstable-v1-protocol.c $flags
    $CC -o river-tags-watch river-tags-watch.c river-status-unstable-v1-protocol.c $flags
    $CC -o river-try river-try.c river-status-unstable-v1-protocol.c \
      river-control-unstable-v1-protocol.c $flags
    # layer-shell's popups refer to xdg-shell's
    $CC -o river-awake river-awake.c idle-inhibit-unstable-v1-protocol.c \
      wlr-layer-shell-unstable-v1-protocol.c xdg-shell-protocol.c $flags
    $CC -o river-outputs-watch river-outputs-watch.c \
      wlr-output-management-unstable-v1-protocol.c $flags
  '';

  installPhase = "install -Dm755 -t $out/bin river-output river-try river-tags-watch river-awake river-outputs-watch";
}
