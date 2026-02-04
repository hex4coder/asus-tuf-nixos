{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "unstable-${src.lastModifiedDate or "latest"}";
  
  # Definisikan paket custom agar kode di bawah lebih rapi
  myGns3Gui = pkgs.gns3-gui.overrideAttrs (old: {
    version = autoVersion gns3-gui-src;
    src = gns3-gui-src;
  });

  myGns3Server = pkgs.gns3-server.overrideAttrs (old: {
    version = autoVersion gns3-server-src;
    src = gns3-server-src;
  });
in
{
  # Pindahkan ke sini, bukan environment.systemPackages
  users.users.kaco = {
    packages = [
      myGns3Gui
      myGns3Server
      pkgs.ubridge
      pkgs.dynamips
      pkgs.vpcs
      pkgs.wireshark
      pkgs.xterm
    ];
    # Pastikan user masuk ke group yang diperlukan
    extraGroups = [ "gns3" "wireshark" "ubridge" ];
  };

  # Konfigurasi sistem tetap diperlukan (karena butuh izin root/setuid)
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "gns3";
  };

  users.groups.gns3 = {};
}
