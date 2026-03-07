{ pkgs, config, ... }:

let
  # GNS3 Custom Builds with Python 3.12 (from gns3.nix)
  python312Packages = pkgs.python312Packages;
  
  gns3-gui-312 = pkgs.gns3-gui.override {
    python3Packages = python312Packages;
  };
  
  gns3-server-312 = (pkgs.gns3-server.override {
    python3Packages = python312Packages;
  }).overrideAttrs (old: {
    doCheck = false;
    dontUsePytestCheck = true;
    doInstallCheck = false;
  });

in
{
  # Alat Lab TJKT (Networking & Troubleshooting)
  environment.systemPackages = with pkgs; [
    # GNS3 & Components
    gns3-gui-312
    gns3-server-312
    ubridge
    dynamips
    vpcs
    xterm

    # Network Analysis
    wireshark
    termshark
    tcpdump
    nmap
    zenmap

    # Troubleshooting & Performance
    iperf3
    mtr
    dig
    speedtest-cli
    
    # Utilities
    ipcalc
    ethtool
    minicom
    tigervnc
    ventoy-full
    
    # Teaching Aids
    screenkey

    # Virtualization & Servers
    virt-manager
    qemu_kvm
    dnsmasq
    winbox4
  ];

  # Winbox Configuration
  programs.winbox = {
    enable = true;
    openFirewall = true;
  };

  # Wireshark Configuration
  programs.wireshark.enable = true;

  # GNS3 Security Wrappers
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o=";
  };

  # Groups for Networking
  users.groups.ubridge = {};
  users.groups.wireshark = {};

  # Ventoy insecure package permission
  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
  ];
}
