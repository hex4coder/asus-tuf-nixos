{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "unstable-${src.lastModifiedDate or "latest"}";

  # Kita definisikan dependensi Python yang dibutuhkan GNS3 v3
  # Versi 3 sering kali butuh PyQt5/6 dan sip yang sinkron
  pythonDeps = ps: with ps; [
    sip
    pyqt5
    setuptools
    # Tambahkan dependensi lain di sini jika nanti muncul error module lagi
  ];
  
  # Definisikan paket custom agar kode di bawah lebih rapi
  myGns3Gui = pkgs.gns3-gui.overrideAttrs (old: {
    version = autoVersion gns3-gui-src;
    src = gns3-gui-src;

    # Kita tambahkan sip dan PyQt ke dalam build inputs
    propagatedBuildInputs = old.propagatedBuildInputs ++ (with pkgs.python3Packages; [
      sip
      pyqt5
    ]);

    # GNS3 v3 seringkali menjalankan tes saat build, 
    # jika tes ini error dan menghambat install, Anda bisa mematikannya sementara:
    doCheck = false;
  });

  myGns3Server = pkgs.gns3-server.overrideAttrs (old: {
    version = autoVersion gns3-server-src;
    src = gns3-server-src;
    # GNS3 v3 seringkali menjalankan tes saat build, 
    # jika tes ini error dan menghambat install, Anda bisa mematikannya sementara:
    doCheck = false;
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
  users.groups.ubridge = {};
}
