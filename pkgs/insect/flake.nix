{
  description = "insect - a scientific calculator with support for physical units (packaged since it's not in nixpkgs)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        insect = pkgs.buildNpmPackage rec {
          pname = "insect";
          version = "5.9.1";

          # Fetched directly from the npm registry: it already contains a
          # prebuilt index.cjs, so we don't need PureScript/spago to build it.
          src = pkgs.fetchurl {
            url = "https://registry.npmjs.org/insect/-/insect-${version}.tgz";
            hash = "sha256-OD43KyNJWL2SR4DHsziOGvvD9EWP22Z+awtCDpXix4U=";
          };

          # Upstream ships neither a package-lock.json in the npm tarball nor
          # in the GitHub repo, which buildNpmPackage needs to fetch deps
          # deterministically. This one was generated from insect's actual
          # published runtime "dependencies" and is checked into this flake
          # directory as package-lock.json.
          postPatch = ''
            cp ${./package-lock.json} package-lock.json
            ${pkgs.jq}/bin/jq 'del(.devDependencies)' package.json > package.json.tmp
            mv package.json.tmp package.json
          '';

          npmDepsHash = "sha256-mLYhD1+vwFBjIZBW/hnhLGyEzVBYMTMbHj9f/i/mka0";


          dontNpmBuild = true; # index.cjs is already prebuilt

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            runHook preInstall

            mkdir -p $out/bin $out/lib/node_modules/insect $out/share/man/man1

            cp -r node_modules $out/lib/node_modules/insect/node_modules
            cp index.cjs $out/lib/node_modules/insect/index.cjs
            cp docs/insect.1 $out/share/man/man1/insect.1

            makeWrapper ${pkgs.nodejs}/bin/node $out/bin/insect \
              --add-flags "$out/lib/node_modules/insect/index.cjs"

            runHook postInstall
          '';

          meta = with pkgs.lib; {
            description = "High precision scientific calculator with support for physical units";
            homepage = "https://github.com/sharkdp/insect";
            license = licenses.mit;
            mainProgram = "insect";
            # Upstream project is archived / unmaintained as of 2026.
          };
        };
      in
      {
        packages.default = insect;
        packages.insect = insect;

        apps.default = {
          type = "app";
          program = "${insect}/bin/insect";
        };
      });
}
