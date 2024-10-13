{ isWSL, inputs, ... }:

{ config, lib, pkgs, ... }:

let
  isDarwin = pkgs.stdenv.isDarwin;
  isLinux = pkgs.stdenv.isLinux;

  # For our MANPAGER env var
  # https://github.com/sharkdp/bat/issues/1145
  manpager = (pkgs.writeShellScriptBin "manpager" (if isDarwin then ''
    sh -c 'col -bx | bat -l man -p'
    '' else ''
    cat "$1" | col -bx | bat --language man --style plain
  ''));
in {
  home.stateVersion = "23.11";

  xdg.enable = true;

  #---------------------------------------------------------------------
  # Packages
  #---------------------------------------------------------------------

  # Packages I always want installed. Most packages I install using
  # per-project flakes sourced with direnv and nix-shell, so this is
  # not a huge list.
  home.packages = [
    pkgs.asciinema
    pkgs.bat
    pkgs.fd
    pkgs.fzf
    pkgs.gh
    pkgs.htop
    pkgs.jq
    pkgs.ripgrep
    pkgs.tree
    pkgs.watch
    pkgs.nurl # generates nix fetch calls from urls
    pkgs.eza

    pkgs.mosh
    pkgs.iperf
    pkgs.lftp
    pkgs.axel


    # Node is required for Copilot.vim
    pkgs.nodejs
  ] ++ (lib.optionals isDarwin [
    # This is automatically setup on Linux
    pkgs.cachix
    pkgs.tailscale
  ]) ++ (lib.optionals (isLinux && !isWSL) [
    pkgs.xfce.xfce4-terminal
  ]);

  #---------------------------------------------------------------------
  # Env vars and dotfiles
  #---------------------------------------------------------------------

  home.sessionVariables = {
    LANG = "en_US.UTF-8";
    LC_CTYPE = "en_US.UTF-8";
    LC_ALL = "en_US.UTF-8";
    EDITOR = "nvim";
    PAGER = "less -FirSwX";
    MANPAGER = "${manpager}/bin/manpager";
    TZ = "Pacific/Auckland";
  };

  #home.file.".gdbinit".source = ./gdbinit;
  #home.file.".inputrc".source = ./inputrc;

  #---------------------------------------------------------------------
  # Programs
  #---------------------------------------------------------------------

  programs.gpg.enable = !isDarwin;


  programs.zsh = {
    enable = true;
    envExtra = ''
    '';

    shellAliases = {
      tn = "tmux new -s ";
      ta = "tmux a -t";
      tl = "tmux ls";
      gs = "git status";
      gpl = "git pull --rebase";
      ls = "eza -l --icons";
    };

    prezto = {
      enable = true;
      # vi mode breaks history search with ctrl+r
      # but  you can press ESC and then / to search forward or ? to search backwards
      editor.keymap = "vi";
      pmodules = [
        "git"
        "syntax-highlighting"
        "history"
        "history-substring-search"
        "completion"
        "prompt"
      ];
    };
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  programs.git = {
    enable = true;
    userName = "Mauro Veron";
    userEmail = "mauroveron@gmail.com";
    #signing = {
    #  key = "523D5DC389D273BC";
    #  signByDefault = true;
    #};
    aliases = {
      cleanup = "!git branch --merged | grep  -v '\\*\\|master\\|develop' | xargs -n 1 -r git branch -d";
      prettylog = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(r) %C(bold blue)<%an>%Creset' --abbrev-commit --date=relative";
      root = "rev-parse --show-toplevel";
      co = "checkout";
    };
    extraConfig = {
      branch.autosetuprebase = "always";
      color.ui = true;
      core.askPass = ""; # needs to be empty to use terminal for ask pass
      credential.helper = "store"; # want to make this more secure
      github.user = "mauroveron";
      push.default = "tracking";
      init.defaultBranch = "main";
    };
  };

  programs.tmux = {
    enable = true;
    terminal = "xterm-256color";
  #  shortcut = "l";
    secureSocket = false;

    extraConfig = ''
      # same prefix as GNU Screen
      set -g prefix C-a
      unbind C-b
      bind C-a send-prefix

      set-option -g default-shell $SHELL
      set-option -g allow-rename off

      set -g default-terminal "screen-256color"

      unbind r
      bind r source-file ~/.tmux.conf \; display "Reloaded ~/.tmux.conf"

      bind C-o split-window -v "tmux list-sessions | sed -E 's/:.*$//' | grep -v \"^$(tmux display-message -p '#S')\$\" | fzf --reverse | xargs tmux switch-client -t"

      unbind ^A
      bind ^A select-pane -t :.+

      # rebind split pane keys and open panes in the current directory
      unbind %
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # start numbering at 1
      set -g base-index 1
      set -g pane-base-index 1
      set-window-option -g pane-base-index 1
      set-option -g renumber-windows on

      # Make Vim responsive to esc
      set -s escape-time 0

      #status bar
      set -g status-bg black
      set -g status-fg white
      set -g status-left '#[fg=green]#H'

      # set window notification
      setw -g monitor-activity on
      set -g visual-activity on

      set-window-option -g window-status-current-style bg=purple

      # navigating trough panes
      unbind h
      unbind j
      unbind k
      unbind l

      # smart pane switching with awareness of vim splits
      bind -n C-h run "(ps -o state= -o comm= -t '#{pane_tty}' | grep -iq nvim && tmux send-keys C-h) || tmux select-pane -L"
      bind -n C-j run "(ps -o state= -o comm= -t '#{pane_tty}' | grep -iq nvim && tmux send-keys C-j) || tmux select-pane -D"
      bind -n C-k run "(ps -o state= -o comm= -t '#{pane_tty}' | grep -iq nvim && tmux send-keys C-k) || tmux select-pane -U"
      bind -n C-l run "(ps -o state= -o comm= -t '#{pane_tty}' | grep -iq nvim && tmux send-keys C-l) || tmux select-pane -R"

      bind -n C-right resize-pane -R 20
      bind -n C-left resize-pane -L 20
      bind -n C-up resize-pane -U 5
      bind -n C-down resize-pane -D 5
    '';
  };

  programs.i3status = {
    enable = isLinux && !isWSL;

    general = {
      colors = true;
      color_good = "#8C9440";
      color_bad = "#A54242";
      color_degraded = "#DE935F";
    };

    modules = {
      ipv6.enable = false;
      "wireless _first_".enable = false;
      "battery all".enable = false;
    };
  };

  programs.neovim =
    let
      toLua = str: "lua <<EOF\n${str}\nEOF";
      toLuaFile = file: "lua <<EOF\n${builtins.readFile file}\nEOF";
    in {

      enable = true;

      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      withPython3 = true;

      plugins = with pkgs; [
        vimPlugins.nord-vim
        vimPlugins.copilot-vim
        vimPlugins.vim-fugitive
        vimPlugins.lsp-zero-nvim
        vimPlugins.nvim-treesitter
        vimPlugins.nvim-treesitter-textobjects
        vimPlugins.plenary-nvim
        vimPlugins.telescope-nvim
        vimPlugins.vim-airline
        vimPlugins.vim-airline-themes
        vimPlugins.vim-gitgutter
        vimPlugins.vim-markdown
        vimPlugins.vim-nix
        vimPlugins.typescript-vim
        vimPlugins.tokyonight-nvim
        vimPlugins.tmux-nvim
        vimPlugins.vim-terraform

        {
          plugin = vimPlugins.nvim-tree-lua;
          config = toLua "require(\"nvim-tree\").setup()";
        }

        vimPlugins.nvim-treesitter-parsers.elixir
        vimPlugins.nvim-treesitter-parsers.nix
        vimPlugins.nvim-treesitter-parsers.python
        vimPlugins.nvim-treesitter-parsers.bash
        vimPlugins.nvim-treesitter-parsers.lua
        vimPlugins.nvim-treesitter-parsers.typescript
        vimPlugins.nvim-treesitter-parsers.go
        vimPlugins.nvim-treesitter-parsers.python
        vimPlugins.nvim-treesitter-parsers.terraform
      ] ++ (lib.optionals (!isWSL) [
    #    # This is causing a segfaulting while building our installer
    #    # for WSL so just disable it for now. This is a pretty
    #    # unimportant plugin anyway.
    #    customVim.vim-devicons
      ]);

      extraPackages = with pkgs; [
        rnix-lsp
        luajitPackages.lua-lsp
        # lsp servers
        gopls
        rnix-lsp
        elixir-ls
      ];

      extraLuaConfig = ''
        ${builtins.readFile ./nvim/options.lua}
        ${builtins.readFile ./nvim/keymaps.lua}
        ${builtins.readFile ./nvim/colors.lua}
      '';

    };

  services.gpg-agent = {
    enable = isLinux;
    pinentryFlavor = "tty";

    # cache the keys forever so we don't get asked for a password
    defaultCacheTtl = 31536000;
    maxCacheTtl = 31536000;
  };

  #xresources.extraConfig = builtins.readFile ./Xresources;

  # Make cursor not tiny on HiDPI screens
  #home.pointerCursor = lib.mkIf (isLinux && !isWSL) {
  #  name = "Vanilla-DMZ";
  #  package = pkgs.vanilla-dmz;
  #  size = 128;
  #  x11.enable = true;
  #};
}

