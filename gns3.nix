{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  sharedPythonPkgs = with pkgs.python3Packages; [
    sip
    pyqt5
    pyqt5-sip
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
  ];

  pythonEnv = pkgs.python3.withPackages (ps: sharedPythonPkgs);

in {
  users.users.kaco.packages = let
    myGns3Gui = pkgs.gns3-gui.overrideAttrs (old: {
      version = autoVersion gns3-gui-src;
      src = gns3-gui-src;
      propagatedBuildInputs = sharedPythonPkgs;

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
        pkgs.makeWrapper 
        pkgs.qt5.wrapQtAppsHook 
      ];

      postFixup = ''
        # Buat file sitecustomize.py secara dinamis untuk memalsukan modul 'sip'
        mkdir -p $out/${pkgs.python3.sitePackages}
        echo "import sys; import PyQt5.sip; sys.modules['sip'] = PyQt5.sip" > $out/${pkgs.python3.sitePackages}/sitecustomize.py

        wrapProgram $out/bin/gns3 \
          --set PYTHONPATH "$out/${pkgs.python3.sitePackages}:${pythonEnv}/${pkgs.python3.sitePackages}"
      '';

      doCheck = false;
      dontUsePytestCheck = true;
      pythonImportsCheck = [ ];
    });

    myGns3Server = pkgs.gns3-server.overrideAttrs (old: {
      version = autoVersion gns3-server-src;
      src = gns3-server-src;
      propagatedBuildInputs = sharedPythonPkgs;
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];

      postFixup = ''
        wrapProgram $out/bin/gns3server \
          --set PYTHONPATH "$out/${pkgs.python3.sitePackages}:${pythonEnv}/${pkgs.python3.sitePackages}"
      '';

      doCheck = false;
      dontUsePytestCheck = true;
      pythonImportsCheck = [ ];
    });
  in [
    myGns3Gui
    myGns3Server
    pkgs.ubridge
    pkgs.dynamips
    pkgs.vpcs
    pkgs.wireshark
    pkgs.xterm 
  ];

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
