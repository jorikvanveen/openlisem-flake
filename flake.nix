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
    
      src = pkgs.fetchzip {
        url = "https://sourceforge.net/code-snapshots/git/q/qw/qwt/git.git/qwt-git-f57e983390b13ddee8c738b36e0044ea4b0c0bf9.zip";
        sha256 = "sha256-2IP23vgltsxFRwhhYgoOxqFeR/L6ljXOtzuAbvsZPQE=";
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
        rev = "e19184939769eff571c4430a035f824db3679201";
        hash = "sha256-iXjH0i5UdEe4gIsewLNIx85HyJIESHhIyOFNkkmTt+Y=";
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
