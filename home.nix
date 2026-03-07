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

    # Modern CLI (Rust-based)
    fd
    bat
  ];

  home.file = {};

  home.sessionVariables = {};

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git Config
  programs.git = {
    enable = true;
    userName = "hex4coder";
    userEmail = "the.programmer.luyo@gmail.com";
    extraConfig = {
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
}
