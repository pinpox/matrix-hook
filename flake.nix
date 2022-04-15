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

  outputs = { nixpkgs, flake-utils, self, ... }:

    {
      nixosModule = ({ pkgs, ... }: {
        imports = [ ./module.nix ];
        # defined overlays injected by the nixflake
        nixpkgs.overlays = [
          (_self: _super: {
            matrix-hook = self.packages.${pkgs.system}.matrix-hook;
          })
        ];
      });
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
