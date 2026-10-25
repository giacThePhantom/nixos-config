# Helper commands, one ./NAME.sh each, installed on PATH so river keybindings,
# the dashboard and the shell can call them by name. Built with
# writeShellApplication: shellcheck runs at build time, `deps` are put on the
# script's PATH and `env` exports Nix values to it.
{
  pkgs,
  inputs,
  colors,
  monitors,
  ...
}:
let
  river-tools = pkgs.callPackage ../pkgs/river-tools { };

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
in
{
  home.packages = [
    river-tools # river-output, river-try
    (script "term" [ pkgs.foot ] { })
    (script "focus-dir" [ river-tools ] { })
    (script "move-dir" [ river-tools ] { })
    (script "tag" [ riverctl river-tools pkgs.river-bnf ] { })
    (script "scratchpad" [ riverctl pkgs.lswt pkgs.jq ] { SCRATCH_TAG = monitors.scratchTag; })
    (script "dash" [ riverctl pkgs.eww ] { PRIMARY_OUTPUT = monitors.primary.name; })
    (script "dash-run" [ riverctl ] { })
    (script "dash-agenda" [ caldir pkgs.jq ] { })
    (script "dash-media" [ pkgs.playerctl pkgs.curl pkgs.jq ] { })
    (script "river-reload" [ pkgs.libnotify ] { })
    (script "clipboard" [ pkgs.cliphist pkgs.fuzzel pkgs.wl-clipboard ] { })
    (script "screenshot" [ pkgs.grim pkgs.slurp pkgs.wl-clipboard pkgs.libnotify ] {
      SLURP_BG = "${colors.bg}88";
      SLURP_BORDER = "${colors.accent}ff";
    })
  ];
}
