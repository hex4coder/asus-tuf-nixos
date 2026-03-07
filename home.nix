{ config, pkgs, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "kaco";
  home.homeDirectory = "/home/kaco";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
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

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.false
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. If you don't want to manage your shell through Home
  # Manager then you have to manually source 'hm-session-vars.sh' located at
  # either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/kaco/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  # Git Config (Moved from configuration.nix)
  programs.git = {
    enable = true;
    userName = "hex4coder";
    userEmail = "the.programmer.luyo@gmail.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  # Bash Config (Moved from configuration.nix)
  programs.bash = {
    enable = true;
    shellAliases = {
      # Shortcut dasar
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
    shellAliases = config.programs.bash.shellAliases; # Share aliases from bash
  };

  programs.starship = {
    enable = true;
    # settings = { ... }; # You can customize starship here
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
