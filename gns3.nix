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

      # STRATEGI: Deteksi indentasi otomatis.
      # Skrip ini mencari baris PRECONFIGURED_VNC_CONSOLE_COMMANDS, 
      # mengambil spasi di depannya, lalu mengganti seluruh bloknya 
      # dengan {} yang memiliki spasi yang sama.
      postPatch = ''
        python3 - <<EOF
        import sys
        import re

        path = 'gns3/settings.py'
        with open(path, 'r') as f:
            content = f.read()

        # Regex ini mencari variabel dari awal nama sampai penutup kurung kurawal '}'
        # Lalu menggantinya dengan variabel yang sama tapi isinya kosong {}
        # Menjaga indentasi (spasi di depan) tetap utuh.
        new_content = re.sub(
            r'(\s+)PRECONFIGURED_VNC_CONSOLE_COMMANDS = \{.*?\}', 
            r'\1PRECONFIGURED_VNC_CONSOLE_COMMANDS = {}', 
            content, 
            flags=re.DOTALL
        )

        with open(path, 'w') as f:
            f.write(new_content)
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
