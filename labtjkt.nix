{ pkgs, ... }:

{
  # Alat Lab TJKT (Networking & Troubleshooting)
  environment.systemPackages = with pkgs; [
    # Network Analysis
    wireshark
    termshark    # Wireshark versi terminal
    tcpdump
    nmap
    zenmap       # GUI untuk nmap

    # Troubleshooting & Performance
    iperf3       # Cek bandwidth
    mtr          # Traceroute + Ping
    dig          # DNS lookup
    speedtest-cli
    
    # Utilities
    ipcalc       # Kalkulator subnetting
    ethtool      # Cek status ethernet fisik
    minicom      # Serial console untuk Router/Switch
    
    # Teaching Aids
    screenkey    # Tampilkan tombol keyboard di layar
  ];

  # Pastikan wireshark bisa dijalankan tanpa sudo oleh user di grup 'wireshark'
  programs.wireshark.enable = true;
}
