# A clean home directory: the XDG folders (Documents, Downloads... and
# .config, .cache, .local) and as few dotfiles as possible. Programs that
# allow it are told to use the XDG folders; bash's own files live in
# ~/.config/bash. What can't move: .ssh (OpenSSH), .pki (NSS, used by
# browsers), .steam* (Steam). docs/11-making-it-yours.md lists one-time moves.
{
  # bash only reads ~/.bash_profile and ~/.bashrc itself; the system files
  # it reads first hand over to ~/.config/bash instead. profile.local runs
  # in /etc/profile before /etc/bashrc; bashrc.local at the very end of
  # /etc/bashrc, after the system's aliases, so ours still win.
  flake.modules.nixos.clean-home = {
    environment.etc."profile.local".text = ''
      if [ -r "$HOME/.config/bash/profile" ]; then . "$HOME/.config/bash/profile"; fi
    '';
    environment.etc."bashrc.local".text = ''
      if [ -n "$PS1" ] && [ -r "$HOME/.config/bash/bashrc" ]; then . "$HOME/.config/bash/bashrc"; fi
    '';
    # ~/.nix-profile, ~/.nix-defexpr -> ~/.local/state/nix
    nix.settings.use-xdg-base-directories = true;
  };

  flake.modules.homeManager.clean-home =
    { config, lib, ... }:
    let
      inherit (config.xdg)
        configHome
        dataHome
        stateHome
        cacheHome
        ;
    in
    {
      xdg.enable = true; # XDG_CONFIG_HOME & co., for the programs below
      # Modules that can choose write to ~/.config (readline: ~/.config/inputrc)
      home.preferXdgDirectories = true;

      home.file.".bashrc".target = lib.mkForce ".config/bash/bashrc";
      home.file.".profile".target = lib.mkForce ".config/bash/profile";
      home.file.".bash_profile".enable = lib.mkForce false; # /etc/profile.local does its job
      programs.bash.historyFile = "${stateHome}/bash/history";

      gtk.gtk2.configLocation = "${configHome}/gtk-2.0/gtkrc"; # not ~/.gtkrc-2.0
      home.pointerCursor.dotIcons.enable = false; # not ~/.icons; XDG data has it

      xdg.configFile."wgetrc".text = "hsts-file = ${cacheHome}/wget-hsts\n";

      home.sessionVariables = {
        # Shells and the terminal
        LESSHISTFILE = "${stateHome}/less/history";
        WGETRC = "${configHome}/wgetrc";
        PYTHON_HISTORY = "${stateHome}/python/history";
        NODE_REPL_HISTORY = "${stateHome}/node/repl_history";
        SQLITE_HISTORY = "${stateHome}/sqlite/history";
        # Languages, when a project brings them
        PYTHONPYCACHEPREFIX = "${cacheHome}/python";
        PYTHONUSERBASE = "${dataHome}/python";
        IPYTHONDIR = "${configHome}/ipython";
        JUPYTER_CONFIG_DIR = "${configHome}/jupyter";
        R_ENVIRON_USER = "${configHome}/R/Renviron";
        R_PROFILE_USER = "${configHome}/R/Rprofile";
        R_LIBS_USER = "${dataHome}/R/%v"; # not ~/R
        R_HISTFILE = "${stateHome}/R/history";
        CARGO_HOME = "${dataHome}/cargo";
        RUSTUP_HOME = "${dataHome}/rustup";
        GOPATH = "${dataHome}/go";
        GOMODCACHE = "${cacheHome}/go/mod";
        NPM_CONFIG_USERCONFIG = "${configHome}/npm/npmrc";
        NPM_CONFIG_CACHE = "${cacheHome}/npm";
        _JAVA_OPTIONS = "-Djava.util.prefs.userRoot=${configHome}/java";
        CONDARC = "${configHome}/conda/condarc";
        # Tools
        GNUPGHOME = "${dataHome}/gnupg";
        PARALLEL_HOME = "${configHome}/parallel"; # GNU parallel, not ~/.parallel
        # Claude Code: ~/.claude and ~/.claude.json both go in here
        CLAUDE_CONFIG_DIR = "${configHome}/claude";
        DOCKER_CONFIG = "${configHome}/docker";
        PULSE_COOKIE = "${configHome}/pulse/cookie";
        # NVIDIA's shader and CUDA caches (not ~/.nv)
        __GL_SHADER_DISK_CACHE_PATH = "${cacheHome}/nv";
        CUDA_CACHE_PATH = "${cacheHome}/nv";
      };

      # Folders some of the above expect to exist
      xdg.stateFile =
        lib.genAttrs
          [
            "less/.keep"
            "python/.keep"
            "node/.keep"
            "sqlite/.keep"
            "R/.keep"
          ]
          (_: {
            text = "";
          });
    };
}
