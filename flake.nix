{
  description = "A flake that build openlisem";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
  };

  outputs = { self, nixpkgs }: let
    qwt = pkgs.stdenv.mkDerivation rec {
      pname = "qwt";
      version = "6.3.0";
    
      outputs = [ "out" "dev" ];
    
      src = pkgs.fetchgit {
        url = "https://git.code.sf.net/p/qwt/git";
        sha256 = "sha256-jgA6iXOf/o3NZ0d7VriFy7KysytleKmUuom4vtpdhQ0=";
        rev = "253cba77048b0d1a3bf42d224fe113a041bd7b1d";
      };
    
      propagatedBuildInputs = [ pkgs.qt6.qtbase pkgs.qt6.qtsvg pkgs.qt6.qttools ];
      nativeBuildInputs = [ pkgs.qt6.qmake ];    
      postPatch = ''
        sed -e "s|QWT_INSTALL_PREFIX.*=.*|QWT_INSTALL_PREFIX = $out|g" -i qwtconfig.pri
      '';
    
      qmakeFlags = [ "-after doc.path=$out/share/doc/qwt-${version}" ];
    
      dontWrapQtApps = true;
    };

    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    packages.x86_64-linux.default = self.packages.x86_64-linux.openlisem;
    packages.x86_64-linux.openlisem = pkgs.stdenv.mkDerivation {
      pname = "openlisem";
      version = "7.2";
      
      src = pkgs.fetchFromGitHub {
        owner = "vjetten";
        repo = "openlisem";
        rev = "26164709f1009ac8987e945434274b21cd19a700";
        hash = "sha256-rAMuP6sWYRnfd234TcEKQtgVaNa2Lm3otr//idRl8MI=";
      };

      env = {
        NIX_QWT = "${qwt}";
      };

      installPhase = ''
        mkdir -p $out/bin
        cp Lisem $out/bin/openlisem
      '';

      buildInputs = [
        pkgs.qt6.qtbase
        pkgs.wayland
        pkgs.gdal
        pkgs.curl
        qwt
      ];

      nativeBuildInputs = [
        pkgs.qt6.wrapQtAppsHook
        pkgs.pkg-config
        pkgs.cmake
      ];
    };
  };
}
