{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  # Satukan semua dependensi Python agar versinya sinkron
  pythonWithDeps = pkgs.python3.withPackages (ps: with ps; [
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
    aiohttp
    aiofiles
    jinja2
    async-timeout
    py-cpuinfo
    platformdirs
  ]);

in {
  users.users.kaco.packages = [
    # GNS3 GUI
    (pkgs.gns3-gui.overrideAttrs (old: {
      version = autoVersion gns3-gui-src;
      src = gns3-gui-src;
      
      # Gunakan nativeBuildInputs untuk menyertakan makeWrapper
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
        pkgs.makeWrapper 
        pkgs.qt5.wrapQtAppsHook 
      ];

      propagatedBuildInputs = [ pythonWithDeps ];

      # Paksa PYTHONPATH agar menunjuk ke library yang benar saat dijalankan
      postInstall = ''
        wrapProgram $out/bin/gns3 \
          --prefix PYTHONPATH : "${pythonWithDeps}/${pkgs.python3.sitePackages}"
      '';

      doCheck = false;
      dontUsePytestCheck = true;
      pythonImportsCheck = [ ];
    }))

    # GNS3 Server
    (pkgs.gns3-server.overrideAttrs (old: {
      version = autoVersion gns3-server-src;
      src = gns3-server-src;
      
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];
      propagatedBuildInputs = [ pythonWithDeps ];

      postInstall = ''
        wrapProgram $out/bin/gns3server \
          --prefix PYTHONPATH : "${pythonWithDeps}/${pkgs.python3.sitePackages}"
      '';

      doCheck = false;
      dontUsePytestCheck = true;
      pythonImportsCheck = [ ];
    }))

    pkgs.ubridge
    pkgs.dynamips
    pkgs.vpcs
    pkgs.wireshark
    pkgs.xterm 
  ];

  # Keamanan & Grup tetap sama
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
