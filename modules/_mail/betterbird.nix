# Betterbird (Thunderbird with extra fixes and features), from its official
# Linux build: it isn't in nixpkgs. Packaged like nixpkgs' thunderbird-bin,
# and wrapped by the same wrapThunderbird (GPG, desktop entry, icons).
# To update: the new file name from https://www.betterbird.eu/downloads/,
# and its hash from `nix store prefetch-file URL`.
{
  lib,
  stdenv,
  fetchurl,
  wrapGAppsHook3,
  autoPatchelfHook,
  patchelfUnstable,
  alsa-lib,
  gtk3,
  writeText,
  wrapThunderbird,
}:
let
  version = "153.6.0esr-bb12";

  # Updates come with the rest of the system, never from Betterbird itself
  policies = writeText "betterbird-policies.json" (
    builtins.toJSON { policies.DisableAppUpdate = true; }
  );

  unwrapped = stdenv.mkDerivation {
    pname = "betterbird-unwrapped";
    inherit version;
    src = fetchurl {
      url = "https://www.betterbird.eu/downloads/LinuxArchive/betterbird-${version}.en-US.linux-x86_64.tar.xz";
      hash = "sha256-nYC2s0Jcl9k87qutPy3gxyLg/QVTHY0to0SVhqhV9B8=";
    };

    nativeBuildInputs = [
      wrapGAppsHook3
      autoPatchelfHook
      patchelfUnstable
    ];
    buildInputs = [ alsa-lib ];
    # Like Thunderbird, it processes its own relocations from a fixed offset
    patchelfFlags = [ "--no-clobber-old-sections" ];

    postPatch = ''
      echo 'pref("app.update.auto", "false");' >> defaults/pref/channel-prefs.js
    '';

    # The wrapper looks for lib/<libName>; a libName starting with
    # "thunderbird" also gives the desktop entry its mail categories and
    # mailto: handling
    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib/thunderbird-betterbird $out/bin
      cp -r * $out/lib/thunderbird-betterbird
      ln -s $out/lib/thunderbird-betterbird/betterbird $out/bin/betterbird
      gappsWrapperArgs+=(--argv0 "$out/bin/.betterbird-wrapped")
      mkdir -p $out/lib/thunderbird-betterbird/distribution
      ln -s ${policies} $out/lib/thunderbird-betterbird/distribution/policies.json
      runHook postInstall
    '';

    passthru = {
      applicationName = "Betterbird";
      binaryName = "betterbird";
      libName = "thunderbird-betterbird";
      inherit gtk3;
      withFFmpeg = true;
      withGSSAPI = true;
    };

    meta = {
      description = "Betterbird, a fine-tuned Thunderbird (binary package)";
      homepage = "https://www.betterbird.eu/";
      license = lib.licenses.mpl20;
      sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
      platforms = [ "x86_64-linux" ];
      mainProgram = "betterbird";
    };
  };
in
wrapThunderbird unwrapped {
  pname = "betterbird";
  libName = "thunderbird-betterbird";
}
