# Lightweight GUI apps and file associations.
{ ... }:
let
  c = import ./palette.nix;
in
{
  programs.mpv = {
    enable = true;
    config = {
      hwdec = "auto-safe";
      vo = "gpu-next";
      profile = "high-quality";
      keep-open = "yes";
    };
  };

  programs.imv = {
    enable = true;
    settings.options.background = c.base;
  };

  programs.zathura = {
    enable = true;
    options = {
      font = "${c.uiFont} 11";
      recolor = true;
      selection-clipboard = "clipboard";
      default-bg = "#${c.base}";
      default-fg = "#${c.text}";
      statusbar-bg = "#${c.mantle}";
      statusbar-fg = "#${c.text}";
      inputbar-bg = "#${c.mantle}";
      inputbar-fg = "#${c.text}";
      recolor-lightcolor = "#${c.base}";
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
