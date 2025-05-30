{
  description = "Build mtr using nix flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }: 
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };

        # Needed tools and libraries
        buildInputs = with pkgs; [
          ncurses.dev
          ncurses.out
          pkg-config
          glib
          inetutils
          gettext
          libcap
        ];

        nativeBuildInputs = with pkgs; [
          automake
          autoconf
          libtool
          libcap
        ];

      in {
        packages.mtr = pkgs.stdenv.mkDerivation {
          pname = "mtr";
          version = "git";

          src = ./.;

          nativeBuildInputs = nativeBuildInputs ++ [ pkgs.pkg-config ];
          buildInputs = buildInputs;

          preConfigure = ''
            export ACLOCAL_FLAGS="-I ${pkgs.pkg-config}/share/aclocal"
            export CPPFLAGS="-I ${pkgs.ncurses.dev}/include"
            export LDFLAGS="-L ${pkgs.ncurses.out}/lib -ltinfo"
            ./bootstrap.sh
          '';

          configureFlags = [];

          meta.description = "mtr network diagnostic tool";
          meta.license = pkgs.lib.licenses.gpl2Plus;
        };

        defaultPackage = self.packages.${system}.mtr;
        devShells.default = pkgs.mkShell {
          buildInputs = buildInputs ++ nativeBuildInputs;
          shellHook = ''
            echo "mtr dev shell ready"
          '';
        };
      });
}

