{ config, pkgs, ... }:

{
  # Docker virtualization
  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
  };
  hardware.nvidia-container-toolkit.enable = true;

  # QEMU/KVM (Libvirtd)
  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      runAsRoot = true;
      verbatimConfig = ''
        user = "kaco"
        group = "libvirtd"
        dynamic_ownership = 1
      '';
    };
  };

  # Fix for failed virt-secret-init-encryption service
  systemd.services.virt-secret-init-encryption = {
    enable = true;
    serviceConfig.ExecStart = [ "" "${pkgs.coreutils}/bin/true" ];
  };

  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  # VirtualBox KVM
  virtualisation.virtualbox.host = {
    enable = true;
    package = pkgs.virtualboxKvm;
  };

  # for waydroid (run android apps)
  virtualisation.waydroid = {
	enable = true;
  };
}
