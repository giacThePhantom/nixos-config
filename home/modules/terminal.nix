# Terminal, shell and CLI tools.
{ pkgs, ... }:
let
  c = import ./palette.nix;
in
{
  programs.foot = {
    enable = true;
    # The server is started by river init; `term` uses footclient
    settings = {
      main = {
        font = "${c.font}:size=11";
        pad = "10x8";
      };
      mouse.hide-when-typing = "yes";
      scrollback.lines = 10000;
      colors-dark = {
        alpha = "0.95";
        # Softer than the UI: --text-secondary on the --bg-card tone (~10:1
        # instead of 18:1). Raise towards c.text / c.base for more contrast.
        foreground = c.subtext1;
        background = c.mantle;
        # regular = strong colour, bright = its lighter "-text" variant
        regular0 = c.surface1;
        regular1 = c.red;
        regular2 = c.green;
        regular3 = c.peach;
        regular4 = c.lavender;
        regular5 = c.mauve;
        regular6 = c.sapphire;
        regular7 = c.subtext0;
        bright0 = c.overlay0;
        bright1 = c.maroon;
        bright2 = c.teal;
        bright3 = c.yellow;
        bright4 = c.blue;
        bright5 = c.pink;
        bright6 = c.sky;
        bright7 = c.text;
        selection-foreground = c.text;
        selection-background = c.surface1;
        urls = c.blue;
      };
    };
  };

  programs.bash = {
    enable = true;
    historyControl = [ "ignoredups" "erasedups" ];
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
        success_symbol = "[❯](bold #${c.mauve})";
        error_symbol = "[❯](bold #${c.red})";
      };
      directory.style = "bold #${c.blue}";
      git_branch.style = "#${c.green}";
      git_status.style = "#${c.peach}";
      nix_shell = {
        format = "[󱄅 $name]($style) ";
        style = "#${c.sapphire}";
      };
      cmd_duration.style = "#${c.yellow}";
    };
  };

  programs.fzf = {
    enable = true;
    defaultCommand = "fd --type f --hidden --exclude .git";
    colors = {
      "bg+" = "#${c.surface0}";
      fg = "#${c.text}";
      "fg+" = "#${c.text}";
      hl = "#${c.mauve}";
      "hl+" = "#${c.mauve}";
      info = "#${c.lavender}";
      prompt = "#${c.mauve}";
      pointer = "#${c.rosewater}";
      marker = "#${c.green}";
      spinner = "#${c.rosewater}";
      header = "#${c.blue}";
      border = "#${c.surface1}";
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
