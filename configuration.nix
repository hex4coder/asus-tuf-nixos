# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.dms.nixosModules.dank-material-shell
      inputs.dms-plugin-registry.modules.default
      inputs.niri.nixosModules.niri
      ./network.nix
      ./samba.nix
      ./aiagent.nix
      ./vscode.nix
      ./labtjkt.nix
      ./virtualisations.nix
    ];

  # flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;
  nix.registry.nixpkgs.flake = inputs.nixpkgs;
  nix.nixPath = [ "nixpkgs=${inputs.nixpkgs}" ];

  # Garbage Collection (Pembersihan Otomatis menggunakan NH)
  programs.nh = {
    enable = true;
    clean.enable = true;
    clean.extraArgs = "--keep-five --keep-since 3d";
    flake = "/home/kaco/dotfiles";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 1;
  boot.kernelPackages = pkgs.linuxPackages_6_12;
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%";

  # Plymouth boot screen
  boot.plymouth = {
    enable = true;
    theme = "rog";
    themePackages = [
      (pkgs.adi1090x-plymouth-themes.override {
        selected_themes = [ "rog" ];
      })
    ];
  };

  boot.consoleLogLevel = 0;
  boot.initrd.verbose = false;
  boot.kernelParams = [
	"nvidia_drm.modeset=1"
	"nvidia_drm.fbdev=1"
	"nvidia.NVreg_PreserveVideoMemoryAllocations=1"
	"nvidia.NVreg_EnableS0ixPowerManagement=1"
	"quiet"
	"splash"
	"boot.shell_on_fail"
	"loglevel=3"
	"rd.systemd.show_status=false"
	"rd.udev.log_level=3"
	"udev.log_priority=3"
  ];
  boot.kernelModules = ["acpi_call"];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  #suspend fix
  boot.initrd.kernelModules = [ "amdgpu" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # networking
  networking.nameservers = [ "1.1.1.1" "1.0.0.1" ];
  networking.hostName = "nixos";

  services.dnsmasq.resolveLocalQueries = false;
  
  # unfree software
  nixpkgs.config.allowUnfree = true;

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Makassar";

  # Enable the X11 windowing system.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
   modesetting.enable = true;
   powerManagement.enable = true;
   open = false;
   nvidiaSettings = true;
   package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  hardware.graphics = {
   enable = true;
   enable32Bit = true;
  };

  # systems envs
  environment.variables = {
   GBM_BACKEND = "nvidia-drm";
   __GLX_VENDOR_LIBRARY_NAME = "nvidia";
   LIBVA_DRIVER_NAME = "nvidia";
   WLR_NO_HARDWARE_CURSORS = "1";
   MOZ_ENABLE_WAYLAND = "1";
   NIXOS_OZONE_WL = "1";
   NIXPKGS_ALLOW_INSECURE = "1";
  };

  # niri
  programs.niri = {
	enable = true;
	package = pkgs.niri;
  };
  
  # thunar
  programs.thunar = {
	enable = true;
  };
  programs.xfconf.enable = true;
  services.gvfs.enable = true;
  services.tumbler.enable = true;

  # greeter
  services.displayManager.dms-greeter = {
	enable = true;
	compositor.name = "niri";
	package = inputs.dms.packages.${pkgs.stdenv.hostPlatform.system}.default;
  };

  # baterai, SSD, & firmware
  services.upower.enable = true;
  services.fstrim.enable = true;
  services.fwupd.enable = true;

  # zram swap
  zramSwap.enable = true;

  # dms shell
  systemd.user.services.niri-flake-polkit.enable = false;
  programs.dank-material-shell = {
	enable = true;
	dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

	plugins = {
		dankBatteryAlerts.enable = true;
	};

	systemd = {
		enable = true;
		restartIfChanged = true;
	};

	enableSystemMonitoring = true;
	enableClipboardPaste = true;
	enableDynamicTheming = true;
	enableAudioWavelength = true;
	enableCalendarEvents = true;
	enableVPN = true;
  };

  # printing search
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # Enable CUPS to print documents.
  services.printing = {
    enable = true;
    cups-pdf.enable = true;
    drivers = with pkgs; [
      gutenprint
      epson-escpr
      epson-escpr2
    ];
  };

  # Enable sound.
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };

  # Enable touchpad support
  services.libinput.enable = true;


  # Define a user account.
  users.users.kaco = {
     isNormalUser = true;
     shell = pkgs.zsh;
     description = "Kaco Jirris";
     extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "kvm" "ubridge" "gns3" "wireshark" "adbusers" "vboxusers" ]; 
  };
  
  # Global Zsh activation
  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestions.enable = true;
    syntaxHighlighting.enable = true;
  };

  # Modern Terminal Tools
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.starship = {
    enable = true;
    settings = {
      format = "[](#9A348E)$os$username[](bg:#DA627D fg:#9A348E)$directory[](fg:#DA627D bg:#FCA17D)$git_branch$git_status[](fg:#FCA17D bg:#86BBD8)$c$elixir$elm$golang$gradle$haskell$java$julia$nodejs$nim$rust$scala[](fg:#86BBD8 bg:#06969A)$docker_context[](fg:#06969A bg:#33658A)$time[ ](fg:#33658A)";
      username = {
        show_always = true;
        style_user = "bg:#9A348E";
        style_root = "bg:#9A348E";
        format = "[$user ]($style)";
        disabled = false;
      };
      os = {
        style = "bg:#9A348E";
        disabled = true;
      };
      directory = {
        style = "bg:#DA627D";
        format = "[ $path ]($style)";
        truncation_length = 3;
        truncation_symbol = "…/";
      };
      directory.substitutions = {
        "Documents" = "󰈙 ";
        "Downloads" = " ";
        "Music" = " ";
        "Pictures" = " ";
      };
      git_branch = {
        symbol = "";
        style = "bg:#FCA17D";
        format = "[ $symbol $branch ]($style)";
      };
      git_status = {
        style = "bg:#FCA17D";
        format = "[$all_status$ahead_behind ]($style)";
      };
      nodejs = {
        symbol = "";
        style = "bg:#86BBD8";
        format = "[ $symbol ($version) ]($style)";
      };
      rust = {
        symbol = "";
        style = "bg:#86BBD8";
        format = "[ $symbol ($version) ]($style)";
      };
      golang = {
        symbol = " ";
        style = "bg:#86BBD8";
        format = "[ $symbol ($version) ]($style)";
      };
      time = {
        disabled = false;
        time_format = "%R";
        style = "bg:#33658A";
        format = "[ ♥ $time ]($style)";
      };
    };
  };

  # untuk kdenlive
  nixpkgs.overlays = [
    (self: super: {
      kdenlive = super.kdePackages.kdenlive.overrideAttrs (oldAttrs: {
        buildInputs = (oldAttrs.buildInputs or []) ++ [ self.shaderc ];
      });
    })
  ];

  # for obs-studio
  programs.obs-studio = {
	enable = true;
	enableVirtualCamera = true;
	plugins = with pkgs.obs-studio-plugins; [
		obs-vaapi
		obs-vkcapture
		obs-pipewire-audio-capture
	];
	package = pkgs.obs-studio.override {
		cudaSupport = true;
	};
  };

  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
     inputs.browseros.packages.${pkgs.stdenv.hostPlatform.system}.default
     wget
     neovim
     curl
     jq

     nvtopPackages.full
     inetutils

     fuzzel
     ghostty
     xwayland
     xwayland-satellite
     gsettings-desktop-schemas
     wl-clipboard
     wl-mirror
     thunar-archive-plugin
     thunar-volman

     brightnessctl
     wireplumber
     asusctl
     libsForQt5.qt5.qtwayland

     #icon themes
     bibata-cursors
     papirus-icon-theme
     tela-icon-theme
     adwaita-icon-theme
     nwg-look 
     #apps
     tor-browser
     onlyoffice-desktopeditors

     # modern cli tools
     fastfetch
     eza
     fzf
     bat
     bottom
  ];

  programs.dconf.enable = true;

  # asus
  programs.rog-control-center = {
	enable = true;
	autoStart = true;
  };
  services.supergfxd.enable = true;
  services.asusd.enable = true;
  systemd.services.asusd.postStart = "${pkgs.asusctl}/bin/asusctl battery limit 80";

  # 1. Aktifkan Hardware Bluetooth
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # 2. GUI Manager
  services.blueman.enable = true;

  # portal gtk
  services.dbus.enable = true;
  security.polkit.enable = true;
  security.rtkit.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome 
      xdg-desktop-portal-wlr
    ];

    config = {
	    common = {
	      default = [ "gtk" ];
	    };
	    niri = {
		default = ["gtk"];
	        "org.freedesktop.impl.portal.ScreenCast" = [ "wlr" ];
	        "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
	    };
	  };
  };
  
  # Set variabel global agar semua aplikasi tahu harus pakai Portal
  environment.sessionVariables = {
    GTK_USE_PORTAL = "1";
    XDG_CURRENT_DESKTOP = "niri"; 
    XDG_SESSION_TYPE = "wayland";
    OBS_USE_EGL = "1";
  };

  system.stateVersion = "25.11";

    # for bash
    programs.bash = {
          enable = true;
          completion.enable = true;
    };
  
          # Fonts management
          fonts.packages = with pkgs; [
            noto-fonts-color-emoji
            fira-code
            fira-code-symbols
            liberation_ttf
            mplus-outline-fonts.githubRelease
          ];
        }
