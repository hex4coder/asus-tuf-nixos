{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  gns3Deps = with pkgs.python3Packages; [
    sip
    pyqt5
    setuptools
    psutil
    jsonschema
    distutils
    raven
    resource
    distro
    setuptools-scm
  ];

in {
  users.users.kaco = {
    packages = [
      # GNS3 GUI dengan Override
      (pkgs.gns3-gui.overrideAttrs (old: {
        version = autoVersion gns3-gui-src;
        src = gns3-gui-src;
        propagatedBuildInputs = gns3Deps;
        doCheck = false;
        doInstallCheck = false;
        dontUsePytestCheck = true;
        pythonImportsCheck = [ ];
        nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
          pkgs.qt5.wrapQtAppsHook 
        ];
      }))

      # GNS3 Server dengan Override
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
        ]);
      }))

      # Emulator & Tools
      pkgs.ubridge
      pkgs.dynamips
      pkgs.vpcs
      pkgs.wireshark
      
      # Terminal Emulator untuk Konsol GNS3
      pkgs.xterm 
    ];
    
    extraGroups = [ "gns3" "ubridge" "wireshark" ];
  };

  # Keamanan ubridge
  security.wrappers.ubridge = {
    source = "${pkgs.ubridge}/bin/ubridge";
    capabilities = "cap_net_admin,cap_net_raw+ep";
    owner = "root";
    group = "ubridge";
    permissions = "u+rx,g+x,o=";
  };

  # Definisi Grup
  users.groups.gns3 = {};
  users.groups.ubridge = {};
}
