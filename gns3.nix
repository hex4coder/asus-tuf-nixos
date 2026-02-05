{ pkgs, ... }:

let
  # Gunakan Python 3.12 packages
  python312Packages = pkgs.python312Packages;
  
  # Override GUI: gunakan Python 3.12 dan matikan test check
  gns3-gui-312 = pkgs.gns3-gui.override {
    python3Packages = python312Packages;
  };
  
  # Override Server: gunakan Python 3.12 dan PAKSA matikan test check
  gns3-server-312 = (pkgs.gns3-server.override {
    python3Packages = python312Packages;
  }).overrideAttrs (old: {
    doCheck = false;
    dontUsePytestCheck = true;
    doInstallCheck = false;
  });

in
{
  # Perbaikan Deprecated Docker Option
  virtualisation.docker.enable = true;
  hardware.nvidia-container-toolkit.enable = true; # Pengganti enableNvidia

  users.users.kaco.packages = [
    gns3-gui-312
    gns3-server-312
    pkgs.ubridge
    pkgs.dynamips
    pkgs.vpcs
    pkgs.wireshark
    pkgs.xterm
  ];

  # Konfigurasi ubridge tetap wajib
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o=";
  };
  
  users.groups.ubridge = {};
  users.groups.wireshark = {};
  programs.wireshark.enable = true;
}
