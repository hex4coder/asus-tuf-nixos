{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  # Dependensi untuk GUI
  gns3GuiDeps = with pkgs.python3Packages; [
    sip
    pyqt5
    setuptools
    psutil
    jsonschema
    distutils
    sentry-sdk
    truststore
    distro
    setuptools-scm
  ];

  # Dependensi untuk Server (Berdasarkan error log Anda)
  gns3ServerDeps = with pkgs.python3Packages; [
    setuptools
    aiohttp
    aiofiles        # Baru
    jinja2          # Baru
    async-timeout   # Baru
    distro          # Baru
    py-cpuinfo      # Baru (biasanya dipanggil cpuinfo di python)
    platformdirs    # Baru
    truststore      # Baru
    jsonschema
    psutil
    sentry-sdk
  ];

in {
  users.users.kaco = {
    packages = [
      # Override GUI
      (pkgs.gns3-gui.overrideAttrs (old: {
        version = autoVersion gns3-gui-src;
        src = gns3-gui-src;
        propagatedBuildInputs = gns3GuiDeps;
        doCheck = false;
        doInstallCheck = false;
        dontUsePytestCheck = true;
        pythonImportsCheck = [ ];
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.qt5.wrapQtAppsHook ];
      }))

      # Override Server
      (pkgs.gns3-server.overrideAttrs (old: {
        version = autoVersion gns3-server-src;
        src = gns3-server-src;
        propagatedBuildInputs = gns3ServerDeps; # Menggunakan list lengkap di atas
        doCheck = false;
        doInstallCheck = false;
        dontUsePytestCheck = true;
        pythonImportsCheck = [ ];
      }))

      pkgs.ubridge
      pkgs.dynamips
      pkgs.vpcs
      pkgs.wireshark
      pkgs.xterm 
    ];
    
    extraGroups = [ "gns3" "ubridge" "wireshark" ];
  };

  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o=";
  };

  users.groups.gns3 = {};
  users.groups.ubridge = {};
}
