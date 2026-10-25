# Lightweight GUI apps and file associations.
{ colors, fonts, ... }:
let
  c = colors;
in
{
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
}
