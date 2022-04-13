{
  description = "Relay prometheus alerts as matrix messages";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, flake-utils, ... }:

    {

      # A Nixpkgs overlay.
      # overlays.default = final: prev: { matrix-hook = final.callPackage self.defaultPackage; };

      nixosModules.matrix-hook = import ./module.nix;

    } //

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {

          matrix-hook = pkgs.callPackage ./pkgs/matrix-hook.nix { };

          mock-hook = pkgs.writeScriptBin "mock-hook" ''
            #!${pkgs.stdenv.shell}
            ${pkgs.curl}/bin/curl -X POST -d @mock.json http://localhost:9088/alert
          '';
        };

        apps = {
          mock-hook = flake-utils.lib.mkApp { drv = packages.mock-hook; };
          matrix-hook = flake-utils.lib.mkApp { drv = packages.matrix-hook; };
        };

        defaultPackage = packages.matrix-hook;
        defaultApp = apps.matrix-hook;
      });
}
