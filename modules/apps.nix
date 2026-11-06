# Lightweight GUI apps and file associations; AppImages run like on any Linux.
{ config, inputs, ... }:
let
  inherit (config) colors fonts;
in
{
  # AppImages (downloaded apps, often from university or vendor sites): run
  # them directly, `./App.AppImage`, or from the file manager
  flake.modules.nixos.apps = {
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };

  flake.modules.homeManager.apps =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      c = colors;
    in
    {
      home.packages = [
        # Upstream v0.8.1 ships a stale pnpm dependency hash; drop this override
        # once a release fixes it.
        (inputs.rencal.packages.${pkgs.stdenv.hostPlatform.system}.default.overrideAttrs (old: {
          pnpmDeps = old.pnpmDeps.overrideAttrs {
            outputHash = "sha256-7A4skNohokIWHI4AjTZJCwWHzL8AYvf3GeqfkQjwwpU=";
          };
        }))
        # Video calls. Its `zoom` command loses to the script of the same name
        # (scripts/zoom.sh), which sets Zoom up for screen sharing; the menu
        # entry runs `zoom` too.
        (lib.lowPrio pkgs.zoom-us)
        # Spotify comes from programs.spicetify (theme/apps.nix)
      ];

      programs.mpv = {
        enable = true;
        config = {
          hwdec = "auto-safe";
          vo = "gpu-next";
          profile = "high-quality";
          keep-open = "yes";
          # On-screen display (seek bar, volume...) in the palette
          osd-color = "#${c.text}";
          osd-border-color = "#${c.bg}";
        };
      };

      programs.imv = {
        enable = true;
        settings.options.background = c.bg;
      };

      programs.zathura = {
        enable = true;
        options = {
          font = "${fonts.ui} 11";
          recolor = true;
          selection-clipboard = "clipboard";
          default-bg = "#${c.bg}";
          default-fg = "#${c.text}";
          statusbar-bg = "#${c.bgCard}";
          statusbar-fg = "#${c.text}";
          inputbar-bg = "#${c.bgCard}";
          inputbar-fg = "#${c.text}";
          recolor-lightcolor = "#${c.bg}";
          recolor-darkcolor = "#${c.text}";
          highlight-color = "rgba(139,92,246,0.4)"; # --accent-glow
          highlight-active-color = "rgba(167,139,250,0.5)"; # --accent-light
        };
      };

      xdg = {
        enable = true;
        userDirs = {
          enable = true;
          createDirectories = true;
          # Folders a desktop without icons or file sharing never uses: no
          # Desktop (the XDG way to say so is pointing it at home), Public
          # or Templates. Documents, Downloads, Music, Pictures, Videos stay.
          desktop = config.home.homeDirectory;
          publicShare = null;
          templates = null;
        };
        mimeApps = {
          enable = true;
          defaultApplications = {
            "x-scheme-handler/rencal" = "renCal.desktop"; # calendar panel event links
            "application/pdf" = "org.pwmt.zathura.desktop";
            "image/png" = "imv.desktop";
            "image/jpeg" = "imv.desktop";
            "image/gif" = "imv.desktop";
            "image/webp" = "imv.desktop";
            "video/mp4" = "mpv.desktop";
            "video/x-matroska" = "mpv.desktop";
            "video/webm" = "mpv.desktop";
            "audio/mpeg" = "mpv.desktop";
            "audio/flac" = "mpv.desktop";
            "text/html" = "firefox.desktop";
            "x-scheme-handler/http" = "firefox.desktop";
            "x-scheme-handler/https" = "firefox.desktop";
            "inode/directory" = "yazi.desktop";
          };
        };
      };
    };
}
