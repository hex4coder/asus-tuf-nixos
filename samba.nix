{ ... }: {
  services.samba = {
    enable = true;
    openFirewall = true; # Otomatis buka port firewall untuk Samba
    settings = {
      global = {
        "workgroup" = "WORKGROUP";
        "server string" = "smbnix";
        "netbios name" = "smbnix";
        "security" = "user";
        # Membantu Windows menemukan server
        "map to guest" = "bad user";
      };
      # Nama folder yang muncul di Windows
      "nixos-share" = {
        "path" = "/home/kaco/Public"; # Sesuaikan folder yang ingin di-share
        "browseable" = "yes";
        "read only" = "no";
        "guest ok" = "yes"; # Izinkan akses tanpa password (opsional)
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "kaco";
      };
    };
  };

  # Tambahkan layanan WSDD agar Windows 10/11 mudah mendeteksi server di Network
  services.samba-wsdd = {
    enable = true;
    openFirewall = true;
  };
}

