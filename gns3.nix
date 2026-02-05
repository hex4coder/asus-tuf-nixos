{ pkgs, gns3-gui-src, gns3-server-src, ... }:

let
  autoVersion = src: "3.0.6-unstable-${src.lastModifiedDate or "latest"}";
  
  sharedPythonPkgs = with pkgs.python3Packages; [
    pyqt6
    pyqt6-sip
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

      # STRATEGI FINAL: 
      # 1. Cari baris yang mengandung PRECONFIGURED_VNC_CONSOLE_COMMANDS.
      # 2. Hapus baris tersebut dan 10 baris di bawahnya (untuk memastikan seluruh isi dictionary Windows terbuang).
      # 3. Masukkan kembali variabel tersebut sebagai dictionary kosong yang valid di satu baris.
      postPatch = ''
        sed -i '/PRECONFIGURED_VNC_CONSOLE_COMMANDS = {/,/}/d' gns3/settings.py
        echo "PRECONFIGURED_VNC_CONSOLE_COMMANDS = {}" >> gns3/settings.py
      '';

      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ 
        pkgs.makeWrapper 
        pkgs.qt6.wrapQtAppsHook 
      ];

      postFixup = ''
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
