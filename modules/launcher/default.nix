# App launcher (Super+Space) and the other pickers (clipboard): rofi, themed as
# a dashboard card (gradient glass, 20px corners, small-caps title), driven
# by scripts/launcher.sh, which puts categories (web apps, capture, setup,
# system, keybindings...) above every app in one searchable list. Web apps
# installed from it run in webapp (_webapp/), a minimal WebKit window.
{ config, ... }:
let
  inherit (config) colors fonts;
in
{
  flake.modules.homeManager.launcher =
    { lib, pkgs, ... }:
    let
      c = colors;

      # One property per line: rofi's parser misreads a string followed by
      # another property on the same line
      rasi = pkgs.writeText "launcher.rasi" ''
        /* The dashboard card: see dashboard/eww/eww.scss */
        * {
          font: "${fonts.ui} 12";
          background-color: transparent;
          text-color: #${c.textSecondary};
          margin: 0;
          padding: 0;
          spacing: 0;
        }
        window {
          location: center;
          anchor: center;
          width: 640px;
          border: 1px;
          border-color: #ffffff1a;
          border-radius: 20px;
          background-color: #${c.bg};
          background-image: linear-gradient(135, #${c.bg}f7, #${c.bgSecondary}f7, #${c.bgTertiary}f7);
          padding: 22px 24px;
        }
        mainbox {
          spacing: 16px;
          children: [ header, inputbar, listview, footer ];
        }

        /* Title (the -mesg, small caps) and match counter */
        header {
          orientation: horizontal;
          expand: false;
          children: [ message, counter ];
        }
        message {
          expand: true;
        }
        textbox {
          markup: true;
          vertical-align: 0.5;
          text-color: #${c.accentLight};
        }
        counter {
          orientation: horizontal;
          expand: false;
          children: [ num-filtered-rows, textbox-num-sep, num-rows ];
        }
        num-filtered-rows, num-rows, textbox-num-sep {
          font: "${fonts.ui} 10";
          text-color: #${c.textMuted};
          vertical-align: 0.5;
        }
        textbox-num-sep {
          content: " / ";
        }

        /* Search field: a glass input */
        inputbar {
          children: [ textbox-search, entry ];
          background-color: #ffffff0d;
          border: 1px;
          border-color: #ffffff14;
          border-radius: 12px;
          padding: 11px 14px;
          spacing: 12px;
        }
        textbox-search {
          expand: false;
          content: "󰍉";
          font: "${fonts.icons} 14";
          text-color: #${c.accentLight};
        }
        entry {
          placeholder: "Search apps and menus";
          placeholder-color: #${c.textPlaceholder};
          text-color: #${c.text};
          cursor: text;
          vertical-align: 0.5;
        }

        /* Entries: icon, bold name, muted description */
        listview {
          lines: 7;
          fixed-height: true;
          scrollbar: false;
          spacing: 4px;
          cycle: true;
        }
        element {
          padding: 8px 12px;
          spacing: 14px;
          border: 1px;
          border-radius: 12px;
          border-color: transparent;
        }
        element selected.normal {
          background-color: #${c.accent}2e;
          border-color: #${c.accent}73;
        }
        element-icon {
          size: 34px;
          vertical-align: 0.5;
        }
        element-text {
          vertical-align: 0.5;
          text-color: inherit;
        }
        element-text selected {
          text-color: #${c.text};
        }

        /* Key hints */
        footer {
          orientation: horizontal;
          expand: false;
          children: [ textbox-hint ];
        }
        textbox-hint {
          content: "<span fgcolor='#${c.accentLight}'>↵</span> open    <span fgcolor='#${c.accentLight}'>esc</span> back    <span fgcolor='#${c.accentLight}'>↑↓</span> move";
          markup: true; /* custom textboxes do not inherit it */
          font: "${fonts.ui} 9";
          text-color: #${c.textMuted};
          horizontal-align: 1.0;
        }
      '';

      # rofi reads its theme only at runtime and then shows an error box:
      # catch syntax errors in the build instead
      theme = pkgs.runCommand "launcher-checked.rasi" { nativeBuildInputs = [ pkgs.rofi-unwrapped ]; } ''
        HOME=$TMPDIR rofi -theme ${rasi} -dump-theme >/dev/null 2>err || true
        if grep -q 'Failed to parse' err; then cat err >&2; exit 1; fi
        cp ${rasi} $out
      '';
    in
    {
      home.packages = [ (pkgs.callPackage ./_webapp { }) ];

      # Plumbing, not apps: hide foot's server and client entries (a user
      # entry with the same id overrides the package's)
      xdg.dataFile =
        lib.genAttrs [ "applications/foot-server.desktop" "applications/footclient.desktop" ]
          (_: {
            text = "[Desktop Entry]\nType=Application\nName=Foot\nNoDisplay=true\n";
          });

      programs.rofi = {
        enable = true;
        theme = "${theme}"; # a path: a derivation would be read as theme attrs
        settings = {
          terminal = "footclient";
          show-icons = true;
          icon-theme = "Papirus-Dark";
          case-sensitive = false;
        };
      };
    };
}
