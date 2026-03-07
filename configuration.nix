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
    ];

  # flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nix.settings.auto-optimise-store = true;

  # auto remove history
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.timeout = 0;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Plymouth boot screen
  boot.plymouth = {
    enable = true;
    theme = "breeze";
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
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # networking
  networking.nameservers = [ "8.8.8.8" ];
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

  # baterai
  services.upower.enable = true;

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

  # docker virtualizations
  virtualisation.docker = {
	enable = true;
	enableOnBoot = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  # qemukvm
  virtualisation.libvirtd = {
	enable = true;
	qemu = {
		runAsRoot = true;
		verbatimConfig = ''
			user = "kaco"
			group = "libvirtd"
			dynamic_ownership = 0
		'';
	};
  };
  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # Enable touchpad support
  services.libinput.enable = true;

  # Define a user account.
  users.users.kaco = {
     isNormalUser = true;
     shell = pkgs.zsh;
     description = "Kaco Jirris";
     extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "kvm" "ubridge" "gns3" "wireshark"]; 
  };
  
  # Global Zsh activation
  programs.zsh.enable = true;

  # untuk kdenlive
  nixpkgs.overlays = [
    (self: super: {
      kdenlive = super.kdenlive.overrideAttrs (oldAttrs: {
        buildInputs = oldAttrs.buildInputs ++ [ self.shaderc ];
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
  ];

  programs.dconf.enable = true;

  # asus
  programs.rog-control-center = {
	enable = true;
	autoStart = true;
  };
  services.supergfxd.enable = true;
  services.asusd.enable = true;

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
}
