{ pkgs, ... }:

{
  # 1. Definisikan Grup secara Eksplisit
  # Ini "memaksa" sistem membuat grup ubridge dan wireshark
  users.groups.ubridge = {};
  users.groups.wireshark = {};

  # 2. Konfigurasi User
  users.users.kaco = {
    extraGroups = [ 
      "ubridge"    # Untuk akses ubridge (kabel antar node)
      "wireshark"  # Untuk sniffing paket
      "libvirtd"   # Jika nanti pakai QEMU/KVM
      "docker"     # Jika pakai node Docker
    ];
  };

  # 3. Paket Aplikasi Utama
  environment.systemPackages = with pkgs; [
    gns3-gui
    gns3-server
    ubridge
    dynamips
    vpcs
    inetutils    # Menyediakan perintah 'telnet' untuk konsol
    wireshark    # GUI untuk sniffing
    xterm        # Terminal default GNS3
  ];

  # 4. Security Wrappers (SANGAT PENTING)
  # Memberikan izin khusus pada binary tanpa harus lari sebagai root
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o=";
  };

  # 5. Konfigurasi Program Tambahan
  programs.wireshark.enable = true;
  programs.wireshark.package = pkgs.wireshark;

  # 6. Izinkan IP Forwarding (Opsional - agar node bisa akses internet via host)
  boot.kernel.sysctl = {
    "net.ipv4.ip_forward" = 1;
  };
}
