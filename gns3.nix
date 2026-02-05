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

      # STRATEGI:
      # 1. Baca baris per baris.
      # 2. Cari baris yang mengandung 'PRECONFIGURED_VNC_CONSOLE_COMMANDS'.
      # 3. Ambil indentasi aslinya, tulis '{}', lalu buang semua baris sampai ketemu '}'.
      postPatch = ''
        python3 - <<EOF
        import sys
        path = 'gns3/settings.py'
        with open(path, 'r') as f:
            lines = f.readlines()
        
        with open(path, 'w') as f:
            inside_target = False
            for line in lines:
                if 'PRECONFIGURED_VNC_CONSOLE_COMMANDS =' in line and not inside_target:
                    # Ambil spasi di depan (indentasi)
                    indent = line[:line.find('PRECONFIGURED_VNC_CONSOLE_COMMANDS')]
                    f.write(f'{indent}PRECONFIGURED_VNC_CONSOLE_COMMANDS = {{}}\n')
                    # Jika dictionary dibuka dengan '{' di baris yang sama, mulai skip
                    if '{' in line and '}' not in line:
                        inside_target = True
                    continue
                
                if inside_target:
                    if '}' in line:
                        inside_target = False
                    continue
                
                f.write(line)
        EOF
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
