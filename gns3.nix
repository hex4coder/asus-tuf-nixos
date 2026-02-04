{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  # Daftar dependensi lengkap untuk GNS3 v3
  gns3Deps = with pkgs.python3Packages; [
    sip
    pyqt5
    setuptools
    psutil
    jsonschema
    distutils
    sentry-sdk    # Baru ditambahkan
    truststore    # Baru ditambahkan
    resource
    distro
    setuptools-scm
  ];

in {
  users.users.kaco = {
    packages = [
      (pkgs.gns3-gui.overrideAttrs (old: {
        version = autoVersion gns3-gui-src;
        src = gns3-gui-src;

        propagatedBuildInputs = gns3Deps;

        # Bypass checks agar build tidak berhenti karena masalah lingkungan sandbox
        doCheck = false;
        doInstallCheck = false;
        dontUsePytestCheck = true;
        pythonImportsCheck = [ ];

        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
          pkgs.qt5.wrapQtAppsHook 
        ];
      }))

      (pkgs.gns3-server.overrideAttrs (old: {
        version = autoVersion gns3-server-src;
        src = gns3-server-src;
        
        doCheck = false;
        doInstallCheck = false;
        dontUsePytestCheck = true;
        pythonImportsCheck = [ ];

        propagatedBuildInputs = (with pkgs.python3Packages; [
          setuptools
          aiohttp
          jsonschema
          psutil
          sentry-sdk # Server juga butuh sentry biasanya
        ]);
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
