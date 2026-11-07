# Helper commands, one ./NAME.sh each, installed on PATH so river keybindings,
# the dashboard and the shell can call them by name. Built with
# writeShellApplication: shellcheck runs at build time, `deps` are put on the
# script's PATH and `env` exports Nix values to it.
{ config, inputs, ... }:
let
  inherit (config) colors monitors settings;
  # Every flake template (dev.nix, bio/) as "NAME=PATH NAME=PATH...", for dvt
  templates = builtins.concatStringsSep " " (
    builtins.attrValues (builtins.mapAttrs (name: t: "${name}=${t.path}") config.flake.templates)
  );
in
{
  flake.modules.homeManager.scripts =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      river-tools = pkgs.callPackage ../river/_river-tools { };

      # The caldir CLI that reads renCal's calendars (~/caldir), without the
      # sync providers renCal already has (15 MB instead of 104 MB)
      caldir =
        let
          full = inputs.rencal.inputs.caldir.packages.${pkgs.stdenv.hostPlatform.system}.default;
        in
        pkgs.runCommand "caldir-cli-${full.version}" { } ''
          install -Dm755 ${full}/bin/.caldir-wrapped $out/bin/caldir
        '';

      script =
        name: deps: env:
        pkgs.writeShellApplication {
          inherit name;
          runtimeInputs = deps;
          runtimeEnv = env;
          text = builtins.readFile ./${name}.sh;
        };

      riverctl = pkgs.river-classic;

      # "keys<TAB>command" for the launcher's Keybindings menu, read from
      # river's own map so it can't go stale: "Super+Shift H" -> "Super+Shift+H",
      # "spawn '/nix/store/…/bin/wpctl set-mute …'" -> "wpctl set-mute …".
      # Super shortcuts first, bare keys (Print, media keys) after.
      keybindings =
        let
          line =
            keys: cmd:
            let
              key = lib.removePrefix "None+" (lib.replaceStrings [ " " ] [ "+" ] keys);
              action = lib.replaceStrings [ "'" ] [ "" ] (
                lib.last (lib.splitString "/bin/" (lib.removePrefix "spawn " cmd))
              );
            in
            "${key}\t${action}\n";
          lines = lib.mapAttrsToList line (config.wayland.windowManager.river.settings.map.normal or { });
          bare = lib.partition (l: !(lib.hasPrefix "Super" l)) lines;
        in
        pkgs.writeText "keybindings" (lib.concatStrings (bare.wrong ++ bare.right));

      # The cheat sheets, checked: the launcher's menu shows each one's first
      # line as its title, and `cheat` opens them in a 1100-pixel window,
      # where lines over 100 columns would wrap
      cheatsheets = pkgs.runCommand "cheatsheets" { } ''
        for f in ${./_cheatsheets}/*; do
          name=''${f##*/}
          case "$name" in
            *.md) ;;
            *) echo "_cheatsheets/$name: sheets are NAME.md files" >&2; exit 1 ;;
          esac
          head -1 "$f" | grep -q '^# .' ||
            { echo "_cheatsheets/$name: the first line must be its title, '# Title'" >&2; exit 1; }
          awk -v f="$name" 'length > 100 { print "_cheatsheets/" f ":" FNR ": over 100 columns"; bad = 1 }
            END { exit bad }' "$f" >&2
        done
        cp -r ${./_cheatsheets} $out
      '';
    in
    {
      home.packages = [
        river-tools # river-output, river-try, river-tags-watch
        (script "term" [ pkgs.foot ] { })
        (script "focus-dir" [ river-tools ] { })
        (script "move-dir" [ river-tools ] { })
        (script "tag" [ riverctl river-tools pkgs.river-bnf ] { })
        (script "scratchpad" [ riverctl pkgs.lswt pkgs.jq ] { SCRATCH_TAG = monitors.scratchTag; })
        (script "dash" [ riverctl pkgs.eww pkgs.procps ] { PRIMARY_OUTPUT = monitors.primary.name; })
        (script "dash-run" [ riverctl ] { })
        (script "dash-agenda" [ caldir pkgs.jq ] { })
        (script "dash-media" [ pkgs.playerctl pkgs.curl pkgs.jq ] { })
        (script "dvt" [ pkgs.fzf pkgs.git pkgs.direnv pkgs.gawk ] { TEMPLATES = templates; })
        (script "launcher" [ riverctl pkgs.rofi pkgs.curl pkgs.libnotify pkgs.gawk pkgs.findutils ] {
          KEYS = "${keybindings}";
          MUTED = colors.textMuted;
          CHEATSHEETS = "${cheatsheets}";
        })
        (script "tag-preview"
          [
            river-tools
            riverctl
            pkgs.eww
            pkgs.jq
            pkgs.gawk
            pkgs.findutils
            pkgs.procps
          ]
          {
            MONITOR_TAGS = lib.concatMapStringsSep " " (
              m: "${m.name}=${lib.concatMapStringsSep "," toString m.tags}"
            ) monitors.all;
          }
        )
        (script "alert" [ pkgs.libnotify ] { })
        (script "hpc-wait" [ pkgs.libnotify pkgs.openssh ] { })
        (script "cheat" [ pkgs.bat pkgs.fzf ] { CHEATSHEETS = "${cheatsheets}"; })
        (script "zk-paper" [ pkgs.papis pkgs.zk pkgs.gawk ] { })
        (script "river-reload" [ pkgs.libnotify ] { })
        (script "dnd" [ pkgs.mako pkgs.libnotify ] { })
        (script "awake" [ river-tools pkgs.libnotify ] { })
        (script "vpn" [ ] {
          GPCLIENT = "${pkgs.gpclient}/bin/gpclient";
          VPN_PORTAL = settings.vpnPortal;
        })
        (script "zoom" [ pkgs.gnused pkgs.bubblewrap ] { ZOOM = "${pkgs.zoom-us}/bin/zoom"; })
        (script "clipboard" [ pkgs.cliphist pkgs.rofi pkgs.wl-clipboard ] { })
        (script "record" [ pkgs.wf-recorder pkgs.slurp pkgs.libnotify river-tools ] {
          SLURP_BG = "${colors.bg}88";
          SLURP_BORDER = "${colors.danger}ff"; # red: recording
        })
        (script "screenshot" [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.libnotify pkgs.satty ] {
          SLURP_BG = "${colors.bg}88";
          SLURP_BORDER = "${colors.accent}ff";
        })
      ];
    };
}
