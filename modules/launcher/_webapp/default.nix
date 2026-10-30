# webapp: a website in its own window (see webapp.c), on the WebKitGTK and
# GTK 3 renCal already brings, so it adds almost nothing to the system.
{
  lib,
  stdenv,
  pkg-config,
  wrapGAppsHook3,
  gtk3,
  webkitgtk_4_1,
  glib-networking,
  gst_all_1,
}:
stdenv.mkDerivation {
  pname = "webapp";
  version = "0.1";
  src = lib.fileset.toSource {
    root = ./.;
    fileset = ./webapp.c;
  };

  # wrapGAppsHook3 points the binary at glib-networking (HTTPS) and the
  # GStreamer plugins (audio/video in pages)
  nativeBuildInputs = [
    pkg-config
    wrapGAppsHook3
  ];
  buildInputs = [
    gtk3
    webkitgtk_4_1
    glib-networking
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
  ];

  buildPhase = ''
    $CC -O2 -Wall -o webapp webapp.c $(pkg-config --cflags --libs gtk+-3.0 webkit2gtk-4.1)
  '';
  installPhase = "install -Dm755 -t $out/bin webapp";
}
