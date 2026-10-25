# Small river helpers that nothing in nixpkgs covers:
#   river-output  print the focused output's name
#   river-try     run river commands until one changes focus
{
  stdenv,
  pkg-config,
  wayland,
  wayland-scanner,
  river-classic,
}:
stdenv.mkDerivation {
  pname = "river-tools";
  version = "0.2";
  src = ./.;

  nativeBuildInputs = [ pkg-config wayland-scanner ];
  buildInputs = [ wayland ];

  buildPhase = ''
    for p in status control; do
      xml=${river-classic.src}/protocol/river-$p-unstable-v1.xml
      wayland-scanner client-header $xml river-$p-unstable-v1-client-protocol.h
      wayland-scanner private-code $xml river-$p-unstable-v1-protocol.c
    done
    flags="-O2 -Wall $(pkg-config --cflags --libs wayland-client)"
    $CC -o river-output river-output.c river-status-unstable-v1-protocol.c $flags
    $CC -o river-try river-try.c river-status-unstable-v1-protocol.c \
      river-control-unstable-v1-protocol.c $flags
  '';

  installPhase = "install -Dm755 -t $out/bin river-output river-try";
}
