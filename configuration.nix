
# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      /etc/nixos/hardware-configuration.nix
      inputs.dms.nixosModules.dank-material-shell
      inputs.dms-plugin-registry.modules.default
      inputs.niri.nixosModules.niri
      ./network.nix
      ./samba.nix
      ./gns3.nix
    ];

  # flakes
  nix.settings.experimental-features = ["nix-command" "flakes"];

  # auto remove history
  nix.gc = {
    automatic = true;
    dates = "weekly"; # Bisa diubah ke "daily" jika ingin setiap hari
    options = "--delete-older-than 30d"; # Hapus yang lebih tua dari 30 hari
  };

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5; # untuk limit history UI 5 saja
  boot.loader.efi.canTouchEfiVariables = true;
  boot.kernelPackages = pkgs.linuxPackages_latest;
  boot.kernelParams = [
	"nvidia_drm.modeset=1"
	"nvidia_drm.fbdev=1"
	"nvidia.NVreg_PreserveVideoMemoryAllocations=1"
#	"acpi_backlight=vendor"
	"nvidia.NVreg_EnableS0ixPowerManagement=1"
  ];
  boot.kernelModules = ["acpi_call"];
  boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  #suspend fix
  boot.initrd.kernelModules = [ "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];

  # networking
  networking.nameservers = [ "8.8.8.8" ];
  networking.hostName = "nixos"; # Define your hostname.

  services.dnsmasq.resolveLocalQueries = false;
  
  # unfree software
  nixpkgs.config.allowUnfree = true;

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Asia/Makassar";

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Select internationalisation properties.
  # i18n.defaultLocale = "en_US.UTF-8";
  # console = {
  #   font = "Lat2-Terminus16";
  #   keyMap = "us";
  #   useXkbConfig = true; # use xkb.options in tty.
  # };

  # Enable the X11 windowing system.
  # services.xserver.enable = true;
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

  #auto cpu freq
  # services.auto-cpufreq.enable = true;
  # services.auto-cpufreq.settings = {
  #  battery = {
  #     governor = "powersave";
  #     turbo = "never";
  #  };
  #  charger = {
  #     governor = "performance";
  #     turbo = "auto";
  #  };
  # };


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


  # dms shell
  systemd.user.services.niri-flake-polkit.enable = false;
  programs.dank-material-shell = {
	enable = true;
	dgop.package = inputs.dgop.packages.${pkgs.stdenv.hostPlatform.system}.default;

	# niri = {
	# 	includes = {
	# 		enable = true;
	# 	};
	#
	# 	enableKeybinds = true;
	# 	enableSpawn = true;
	# };
	#
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


  

  # Configure keymap in X11
  # services.xserver.xkb.layout = "us";
  # services.xserver.xkb.options = "eurosign:e,caps:escape";

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
  # services.pulseaudio.enable = true;
  # OR
  services.pipewire = {
     enable = true;
     pulse.enable = true;
  };

  # docker virtualizations
  virtualisation.docker = {
	enable = true;
	enableNvidia = true;
	enableOnBoot = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  # qemukvm
  # Enable virtualization
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


  # Enable touchpad support (enabled default in most desktopManager).
  services.libinput.enable = true;



  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.kaco = {
     isNormalUser = true;
     description = "Kaco Jirris";
     extraGroups = [ "wheel" "networkmanager" "docker" "libvirtd" "kvm" "ubridge" "gns3"]; 
     packages = with pkgs; [
     	vlc
     	peazip
	tigervnc
       	tree
	      firefox
	      google-chrome
	      antigravity
	      rustdesk
	      fastfetch
        signal-desktop
	unzip
	ventoy-full
	zoom-us





	# DKV
	gimp
	blender
	krita
	inkscape
	#kdePackages.kdenlive
     ];
  };
  # untuk kdenlive
  nixpkgs.overlays = [
    (self: super: {
      kdenlive = super.kdenlive.overrideAttrs (oldAttrs: {
        # Kita tambahkan shaderc ke dalam buildInputs secara paksa
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

  # for ventoy
  nixpkgs.config.permittedInsecurePackages = [
                "ventoy-1.1.10"
              ];

  # Git Config
  programs.git = {
	enable = true;
	config = {
		user = {
			name = "hex4coder";
			email = "the.programmer.luyo@gmail.com";
		};
		init.defaultBranch = "main";
	};

  };

  # programs.firefox.enable = true;

  # List packages installed in system profile.
  # You can use https://search.nixos.org/ to find more packages (and options).
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
     #rog-control-center
     libsForQt5.qt5.qtwayland

     #icon themes
     bibata-cursors
     papirus-icon-theme
     tela-icon-theme
     adwaita-icon-theme
     nwg-look 
     #apps
     onlyoffice-desktopeditors


     # for student in tjkt
     virt-manager
     qemu_kvm
     dnsmasq
  ];

  # for gns3 server service
	#  services.gns3-server = {
	# enable = false;
	# ubridge.enable = true;
	# vpcs.enable = true;
	# dynamips.enable = true;
	#  };
  users.groups.ubridge = {};
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw=ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x";
  };

  programs.dconf.enable = true;

  # asus
  programs.rog-control-center = {
	enable = true;
	autoStart = true;
  };
  services.supergfxd.enable = true;
  services.asusd.enable = true;
  services.asusd.enableUserService = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # 1. Aktifkan Hardware Bluetooth
  hardware.enableAllFirmware = true;
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false; # Matikan otomatis saat boot
    settings = {
      General = {
        Enable = "Source,Sink,Media,Socket";
      };
    };
  };

  # 2. GUI Manager (PENTING untuk Niri)
  services.blueman.enable = true;






  # portal gtk
  services.dbus.enable = true;
  security.polkit.enable = true;
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true; # Paksa xdg-open pakai portal
    
    # 1. Instal backend portal
    # 'xdg-desktop-portal-gtk' adalah yang paling ringan dan kompatibel untuk file picker
    extraPortals = with pkgs; [
      xdg-desktop-portal-gtk
      xdg-desktop-portal-gnome 
      # Opsional, jika butuh fitur GNOME spesifik
    ];

    # 2. Konfigurasi Mapping (PENTING)
    # Ini memberitahu sistem: "Saat di Niri, gunakan portal GTK untuk dialog file"
    config.common.default = "*";
  };
  
  # Set variabel global agar semua aplikasi tahu harus pakai Portal
  environment.sessionVariables = {
    GTK_USE_PORTAL = "1";
    # Kadang Electron butuh tahu dia dianggap "GNOME" agar mau pakai portal
    XDG_CURRENT_DESKTOP = "niri"; 
    XDG_SESSION_TYPE = "wayland";
    OBS_USE_EGL = "1";
  };

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # Copy the NixOS configuration file and link it from the resulting system
  # (/run/current-system/configuration.nix). This is useful in case you
  # accidentally delete configuration.nix.
  # system.copySystemConfiguration = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?



  # for bash
  programs.bash = {
	enable = true;
	completion.enable = true;
	shellAliases = {
# Shortcut dasar
      g = "git";
      
      # Status & Add
      gs = "git status";
      ga = "git add";
      gaa = "git add --all";
      
      # Commit
      gc = "git commit -am";
      gca = "git commit --amend";
      
      # Push & Pull
      gp = "git push";
      gl = "git pull";
      
      # Branch & Checkout
      gb = "git branch";
      gco = "git checkout";
      gcb = "git checkout -b"; # Buat branch baru dan pindah
      
      # Diff & Log
      gd = "git diff";
      glog = "git log --oneline --decorate --graph"; # Log yang rapi
      
      # Stash
      gsta = "git stash push";
      gstp = "git stash pop";

      # for nix os rebuild
      ncb = "sudo nixos-rebuild switch --impure --flake --upgrade";
	};
  };

}

