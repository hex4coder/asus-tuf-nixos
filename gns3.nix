{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  sharedPythonPkgs = with pkgs.python3Packages; [
    sip
    pyqt5
    pyqt5-sip        # PERBAIKAN: Gunakan tanda hubung (-) bukan underscore (_)
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
  users.users.kaco.packages = [
    (pkgs.gns3-gui.overrideAttrs (old: {
      version = autoVersion gns3-gui-src;
      src = gns3-gui-src;
      propagatedBuildInputs = sharedPythonPkgs;

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
        pkgs.makeWrapper 
        pkgs.qt5.wrapQtAppsHook 
      ];

      postFixup = ''
        wrapProgram $out/bin/gns3 \
          --prefix PYTHONPATH : "${pythonEnv}/${pkgs.python3.sitePackages}" \
          --set QT_QPA_PLATFORM_PLUGIN_PATH "${pkgs.qt5.qtbase.bin}/lib/qt-${pkgs.qt5.qtbase.version}/plugins/platforms"
      '';

      doCheck = false;
      dontUsePytestCheck = true;
      pythonImportsCheck = [ ];
    }))

    (pkgs.gns3-server.overrideAttrs (old: {
      version = autoVersion gns3-server-src;
      src = gns3-server-src;
      propagatedBuildInputs = sharedPythonPkgs;

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.makeWrapper ];

      postFixup = ''
        wrapProgram $out/bin/gns3server \
          --prefix PYTHONPATH : "${pythonEnv}/${pkgs.python3.sitePackages}"
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
