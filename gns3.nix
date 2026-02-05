{ pkgs, ... }:

let
  # Memaksa penggunaan Python 3.12 untuk GNS3
  python312Packages = pkgs.python312Packages;
  
  gns3-gui-312 = pkgs.gns3-gui.override {
    python3Packages = python312Packages;
  };
  
  gns3-server-312 = pkgs.gns3-server.override {
    python3Packages = python312Packages;
  };
in
{
  users.users.kaco.packages = [
    gns3-gui-312
    gns3-server-312
    pkgs.ubridge
    pkgs.dynamips
    pkgs.vpcs
    pkgs.wireshark
    pkgs.xterm
  ];

  # Wrapper tetap sama seperti sebelumnya
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o=";
  };
  
  users.groups.ubridge = {};
}
