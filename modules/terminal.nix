# Terminal, shell and CLI tools.
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.homeManager.terminal =
    {
      pkgs,
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

      # readline: the line editor of bash (and of other prompts that use it,
      # like R's or sqlite's). Plain bash, nothing installed: these settings
      # make it closer to what plugins for other shells do.
      programs.readline = {
        enable = true;
        variables = {
          # Tab: case doesn't matter, - and _ are the same, every match is
          # listed at once (with colours, folders marked) instead of a beep
          completion-ignore-case = true;
          completion-map-case = true;
          show-all-if-ambiguous = true;
          colored-stats = true;
          colored-completion-prefix = true;
          mark-symlinked-directories = true;
          skip-completed-text = true;
          bell-style = "none";
          # Esc must not wait half a second to see if it starts a key sequence
          keyseq-timeout = 50;
        };
        extraConfig = ''
          $if Bash
            # Vim keys on bash's command line: Esc for normal mode. The
            # cursor shows the mode: a bar when typing, a block in normal mode.
            set editing-mode vi
            set show-mode-in-prompt on
            set vi-ins-mode-string "\1\e[6 q\2"
            set vi-cmd-mode-string "\1\e[2 q\2"

            set keymap vi-insert
            # Up/Down: only the commands that start with what's typed
            "\e[A": history-search-backward
            "\e[B": history-search-forward
            # A few habits from the default mode, while typing
            "\C-l": clear-screen
            "\C-a": beginning-of-line
            "\C-e": end-of-line
            "\e.": yank-last-arg
            "\C-x\C-e": edit-and-execute-command

            set keymap vi-command
            "\e[A": history-search-backward
            "\e[B": history-search-forward
            "k": history-search-backward
            "j": history-search-forward
            "\C-l": clear-screen
          $endif
        '';
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

      # Terminal multiplexer, only on request (Super+Alt+Return); plain
      # terminals stay plain. It starts locked, so every key reaches the
      # programs inside; Ctrl+Space then one key acts on zellij and locks
      # again, like tmux's prefix and with herdr's keys (below).
      programs.zellij = {
        enable = true;
        enableBashIntegration = false; # would start it in every shell
        settings = {
          theme = "system";
          # Same mapping as foot's colours; `bg` is the selection/frame colour
          themes.system = {
            fg = "#${c.textSecondary}";
            bg = "#${c.bgSecondary}";
            black = "#${c.bgCard}";
            red = "#${c.danger}";
            green = "#${c.success}";
            yellow = "#${c.warningText}";
            blue = "#${c.gradientStart}";
            magenta = "#${c.accent}";
            cyan = "#${c.info}";
            white = "#${c.text}";
            orange = "#${c.warning}";
          };
          default_layout = "compact";
          default_mode = "locked";
          pane_frames = false;
          show_startup_tips = false;
          show_release_notes = false;
        };
        extraConfig = ''
          keybinds clear-defaults=true {
              locked {
                  bind "Ctrl Space" { SwitchToMode "tmux"; }
              }
              tmux {
                  bind "Ctrl Space" "Esc" { SwitchToMode "locked"; }
                  bind "v" { NewPane "Right"; SwitchToMode "locked"; }
                  bind "-" { NewPane "Down"; SwitchToMode "locked"; }
                  bind "h" "Left" { MoveFocus "Left"; SwitchToMode "locked"; }
                  bind "j" "Down" { MoveFocus "Down"; SwitchToMode "locked"; }
                  bind "k" "Up" { MoveFocus "Up"; SwitchToMode "locked"; }
                  bind "l" "Right" { MoveFocus "Right"; SwitchToMode "locked"; }
                  bind "x" { CloseFocus; SwitchToMode "locked"; }
                  bind "z" { ToggleFocusFullscreen; SwitchToMode "locked"; }
                  bind "f" { ToggleFloatingPanes; SwitchToMode "locked"; }
                  bind "r" { SwitchToMode "resize"; }
                  bind "[" { SwitchToMode "scroll"; }
                  bind "c" { NewTab; SwitchToMode "locked"; }
                  bind "n" { GoToNextTab; SwitchToMode "locked"; }
                  bind "p" { GoToPreviousTab; SwitchToMode "locked"; }
                  bind "1" { GoToTab 1; SwitchToMode "locked"; }
                  bind "2" { GoToTab 2; SwitchToMode "locked"; }
                  bind "3" { GoToTab 3; SwitchToMode "locked"; }
                  bind "4" { GoToTab 4; SwitchToMode "locked"; }
                  bind "5" { GoToTab 5; SwitchToMode "locked"; }
                  bind "6" { GoToTab 6; SwitchToMode "locked"; }
                  bind "7" { GoToTab 7; SwitchToMode "locked"; }
                  bind "8" { GoToTab 8; SwitchToMode "locked"; }
                  bind "9" { GoToTab 9; SwitchToMode "locked"; }
                  bind "T" { SwitchToMode "renametab"; TabNameInput 0; }
                  bind "w" {
                      LaunchOrFocusPlugin "session-manager" { floating true; move_to_focused_tab true; }
                      SwitchToMode "locked"
                  }
                  bind "d" "q" { Detach; }
              }
              resize {
                  bind "h" "Left" { Resize "Increase Left"; }
                  bind "j" "Down" { Resize "Increase Down"; }
                  bind "k" "Up" { Resize "Increase Up"; }
                  bind "l" "Right" { Resize "Increase Right"; }
                  bind "H" { Resize "Decrease Left"; }
                  bind "J" { Resize "Decrease Down"; }
                  bind "K" { Resize "Decrease Up"; }
                  bind "L" { Resize "Decrease Right"; }
                  bind "Esc" "Enter" "Ctrl Space" { SwitchToMode "locked"; }
              }
              scroll {
                  bind "j" "Down" { ScrollDown; }
                  bind "k" "Up" { ScrollUp; }
                  bind "Ctrl d" "PageDown" { HalfPageScrollDown; }
                  bind "Ctrl u" "PageUp" { HalfPageScrollUp; }
                  bind "/" { SwitchToMode "entersearch"; SearchInput 0; }
                  bind "e" { EditScrollback; SwitchToMode "locked"; }
                  bind "Esc" "q" "Ctrl Space" { ScrollToBottom; SwitchToMode "locked"; }
              }
              entersearch {
                  bind "Enter" { SwitchToMode "search"; }
                  bind "Esc" { SwitchToMode "scroll"; }
              }
              search {
                  bind "n" { Search "down"; }
                  bind "N" { Search "up"; }
                  bind "j" "Down" { ScrollDown; }
                  bind "k" "Up" { ScrollUp; }
                  bind "Esc" "q" "Ctrl Space" { ScrollToBottom; SwitchToMode "locked"; }
              }
              renametab {
                  bind "Enter" { SwitchToMode "locked"; }
                  bind "Esc" { UndoRenameTab; SwitchToMode "locked"; }
              }
          }
        '';
      };

      # herdr (Super+Ctrl+Return): the same leader as zellij, Ctrl+Space; its
      # colours follow the terminal's (the palette). Read-only, from here:
      # its settings screen can't save, change it in this file.
      xdg.configFile."herdr/config.toml".text = ''
        onboarding = false

        [keys]
        prefix = "ctrl+space"

        [theme]
        name = "terminal"
      '';

      programs.zoxide.enable = true; # `z dir`
      programs.eza.enable = true;
      programs.bat = {
        enable = true;
        config.theme = "base16";
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
      programs.tealdeer = {
        enable = true; # `tldr tar`: examples instead of man pages
        settings.updates.auto_update = true;
      };

      home.packages = with pkgs; [
        ripgrep
        fd
        jq
        unzip
        p7zip
        wget
        nixfmt
        libqalculate # `qalc "2 mL * 250 mmol/L to mmol"`: a calculator that knows units
      ];
    };
}
