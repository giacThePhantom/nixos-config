# Terminal, shell and CLI tools.
{
  pkgs,
  colors,
  fonts,
  ...
}:
let
  c = colors;
in
{
  programs.foot = {
    enable = true;
    # The server is started by river init; `term` uses footclient
    settings = {
      main = {
        font = "${fonts.mono}:size=11,${fonts.iconsMono}:size=11";
        pad = "10x8";
      };
      mouse.hide-when-typing = "yes";
      scrollback.lines = 10000;
      colors-dark = {
        alpha = "0.95";
        # Softer than the UI: --text-secondary on the --bg-card tone (~10:1
        # instead of 18:1). Raise towards c.text / c.bg for more contrast.
        foreground = c.textSecondary;
        background = c.bgCard;
        # regular = strong colour, bright = its lighter "-text" variant
        regular0 = c.bgSecondary;
        regular1 = c.danger;
        regular2 = c.success;
        regular3 = c.warning;
        regular4 = c.gradientStart;
        regular5 = c.accent;
        regular6 = c.info;
        regular7 = c.textMutedStrong;
        bright0 = c.textPlaceholder;
        bright1 = c.dangerText;
        bright2 = c.successText;
        bright3 = c.warningText;
        bright4 = c.infoText;
        bright5 = c.accentLight;
        bright6 = c.infoLight;
        bright7 = c.text;
        selection-foreground = c.text;
        selection-background = c.bgSecondary;
        urls = c.infoText;
      };
    };
  };

  programs.bash = {
    enable = true;
    historyControl = [
      "ignoredups"
      "erasedups"
    ];
    historySize = 50000;
    shellAliases = {
      ls = "eza --icons --group-directories-first";
      ll = "eza -l --icons --git --group-directories-first";
      la = "eza -la --icons --git --group-directories-first";
      tree = "eza --tree --icons";
      cat = "bat --paging=never";
      rebuild = "sudo nixos-rebuild switch --flake ~/.config/nixos#nixos";
    };
  };

  # Native binary, renders in ~1ms; only a few modules enabled
  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$nix_shell$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](bold #${c.accent})";
        error_symbol = "[❯](bold #${c.danger})";
      };
      directory.style = "bold #${c.infoText}";
      git_branch.style = "#${c.success}";
      git_status.style = "#${c.warning}";
      nix_shell = {
        format = "[󱄅 $name]($style) ";
        style = "#${c.info}";
      };
      cmd_duration.style = "#${c.warningText}";
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    colors = {
      "bg+" = "#${c.bgTertiary}";
      fg = "#${c.text}";
      "fg+" = "#${c.text}";
      hl = "#${c.accent}";
      "hl+" = "#${c.accent}";
      info = "#${c.gradientStart}";
      prompt = "#${c.accent}";
      pointer = "#${c.accentLight}";
      marker = "#${c.success}";
      spinner = "#${c.accentLight}";
      header = "#${c.infoText}";
      border = "#${c.bgSecondary}";
    };
  };

  programs.zoxide.enable = true; # `z dir`
  programs.eza.enable = true;
  programs.bat = {
    enable = true;
    config.theme = "base16";
  };
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true; # per-project `use flake` dev shells
  };
  programs.btop = {
    enable = true;
    settings = {
      color_theme = "TTY";
      theme_background = false;
      vim_keys = true;
      update_ms = 1000;
    };
  };
  programs.yazi = {
    enable = true;
    shellWrapperName = "y"; # `y` = yazi that cd's on exit
  };
  programs.fastfetch.enable = true;

  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    # Colour scheme from the palette, on the terminal's background
    plugins = [
      {
        plugin = pkgs.vimPlugins.mini-base16;
        type = "lua";
        config = ''
          require("mini.base16").setup({ palette = {
            base00 = "#${c.bgCard}", base01 = "#${c.bgTertiary}",
            base02 = "#${c.bgSecondary}", base03 = "#${c.textMuted}",
            base04 = "#${c.textMutedStrong}", base05 = "#${c.textSecondary}",
            base06 = "#${c.text}", base07 = "#${c.text}",
            base08 = "#${c.dangerText}", base09 = "#${c.warning}",
            base0A = "#${c.warningText}", base0B = "#${c.successText}",
            base0C = "#${c.info}", base0D = "#${c.infoText}",
            base0E = "#${c.accentLight}", base0F = "#${c.accent}",
          } })
        '';
      }
    ];
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    jq
    unzip
    p7zip
    wget
    nixfmt
  ];
}
