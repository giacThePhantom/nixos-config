# The boot splash: instead of kernel and systemd messages, Plymouth shows the
# branded wallpaper (the one river puts on the primary monitor, so boot hands
# over to the desktop without a jump) with a progress bar under the name.
# Esc during boot shows the messages again.
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.nixos.theme =
    { pkgs, lib, ... }:
    let
      wallpaper = import ./_wallpaper.nix { inherit pkgs colors fonts; };

      # "r, g, b" from 0 to 1, as Plymouth's script wants colours
      rgb =
        hex:
        lib.concatMapStringsSep ", " (i: toString (lib.fromHexString (builtins.substring i 2 hex) / 255.0))
          [
            0
            2
            4
          ];

      script = pkgs.replaceVars ./_branding/splash.script {
        bg = rgb colors.bg;
        text = rgb colors.text;
        textMuted = rgb colors.textMuted;
        font = fonts.mono;
      };

      theme =
        pkgs.runCommand "plymouth-theme-enjoythelab" { nativeBuildInputs = [ pkgs.imagemagick ]; }
          ''
            dir=$out/share/plymouth/themes/enjoythelab
            mkdir -p $dir
            # The monitors are 1080p; 4K would only make the initrd bigger
            magick ${wallpaper.branded} -resize 1920x1080 $dir/wallpaper.png
            magick -size 1x1 xc:'#${colors.borderHeavy}' $dir/track.png
            magick -size 1x1 xc:'#${colors.logoEnjoy}' $dir/bar.png
            cp ${script} $dir/enjoythelab.script
            cat > $dir/enjoythelab.plymouth <<EOF
            [Plymouth Theme]
            Name=EnjoyTheLab
            Description=EnjoyTheLab logo with a progress bar
            ModuleName=script

            [script]
            ImageDir=$dir
            ScriptFile=$dir/enjoythelab.script
            EOF
          '';
    in
    {
      boot.plymouth = {
        enable = true;
        theme = "enjoythelab";
        themePackages = [ theme ];
        font = "${pkgs.jetbrains-mono}/share/fonts/truetype/JetBrainsMono-Regular.ttf";
      };

      # Quiet boot: only errors reach the screen (Plymouth covers the rest)
      boot.consoleLogLevel = 3;
      boot.kernelParams = [
        "quiet"
        "udev.log_level=3"
        "systemd.show_status=auto"
      ];
    };
}
