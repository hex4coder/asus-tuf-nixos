{ config, pkgs, ... }:

{
  home.username = "kaco";
  home.homeDirectory = "/home/kaco";

  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    vlc
    peazip
    tree
    firefox
    google-chrome
    antigravity
    rustdesk
    fastfetch
    signal-desktop
    unzip
    zoom-us
    btop

    # DKV
    gimp
    blender
    krita
    inkscape
    audacity

    # Modern CLI (Rust-based)
    fd
    bat
    nh
    
    # Fonts
    inter
    nerd-fonts.jetbrains-mono
  ];

  fonts.fontconfig.enable = true;

  home.file = {};

  home.sessionVariables = {
    NH_FLAKE = "/home/kaco/dotfiles";
  };
  
  # Direnv Config
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };

  # Tmux Config
  programs.tmux = {
    enable = true;
    mouse = true;
    baseIndex = 1;
    clock24 = true;
    extraConfig = ''
      # Set prefix to Ctrl-a (optional, default is Ctrl-b)
      # set -g prefix C-a
      # bind C-a send-prefix
      
      # Split panes using | and -
      bind | split-window -h
      bind - split-window -v
      unbind '"'
      unbind %

      # Resize panes lebih cepat dengan H, J, K, L
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
    '';
  };

  # Dark/Light Mode Consistency (GSettings)
  dconf.settings = {
    "org/gnome/desktop/interface" = {
      color-scheme = "prefer-dark";
    };
  };

  # QT Config for consistency
  qt = {
    enable = true;
    platformTheme.name = "gtk";
    style.name = "adwaita-dark";
  };

  # Pointer Cursor Config
  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name = "Bibata-Modern-Amber";
    size = 24;
    gtk.enable = true;
    x11.enable = true;
  };

  # GTK Theme Config
  gtk = {
    enable = true;
    theme = {
      name = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Tela-orange-dark";
      package = pkgs.tela-icon-theme;
    };
    gtk3.extraConfig = {
      gtk-recent-files-enabled = 0;
    };
    gtk3.extraCss = ''
      @import url("file:///home/kaco/.config/gtk-3.0/dank-colors.css");
      headerbar {
        margin-top: -100px;
        opacity: 0;
      }
      window.maximized headerbar,
      window.fullscreen headerbar {
        margin-top: 0;
        opacity: 1;
      }
    '';
    gtk4.extraConfig = {
      gtk-recent-files-enabled = 0;
    };
    gtk4.extraCss = ''
      @import url("file:///home/kaco/.config/gtk-3.0/dank-colors.css");
      headerbar {
        margin-top: -100px;
        opacity: 0;
      }
    '';
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git Config (Refactored to settings)
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "hex4coder";
        email = "the.programmer.luyo@gmail.com";
      };
      init.defaultBranch = "main";
    };
  };

  # Bash Config
  programs.bash = {
    enable = true;
    shellAliases = {
      g = "git";
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      gc = "git commit -am";
      gca = "git commit --amend";
      gp = "git push";
      gl = "git pull";
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b";
      gd = "git diff";
      glog = "git log --oneline --decorate --graph";
      gsta = "git stash push";
      gstp = "git stash pop";
      ncb = "sudo nixos-rebuild switch --impure --flake . --upgrade";
      n-up = "git pull && nix flake update && sudo nixos-rebuild switch --impure --flake . && git add flake.lock && git commit -m 'chore: system update' && git push";
      nos = "nh os switch . -- --impure";
      noh = "nh os switch . -u -- --impure";
      n-clean = "nh clean all --keep 5";
      
      # GTK Theme Switchers
      set-dark = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-dark' && gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'";
      set-light = "gsettings set org.gnome.desktop.interface color-scheme 'prefer-light' && gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita'";
    };
  };

  # Modern CLI Tools
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = config.programs.bash.shellAliases;
  };

  programs.starship = {
    enable = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  programs.eza = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
    icons = "auto";
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    enableBashIntegration = true;
  };

  # Config Links
  xdg.configFile."niri".source = ./niri;
  xdg.configFile."fuzzel".source = ./fuzzel;
}
