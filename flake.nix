{
  description = "HTTP (webhook) listener to announce messages in IRC channels";
  inputs.flake-utils.url = "github:numtide/flake-utils";

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      with nixpkgs.legacyPackages.${system}; rec {

        packages = flake-utils.lib.flattenTree rec {

          matrix-hook = buildGoModule rec {

            pname = "matrix-hook";
            version = "1.0.0";

            src = ./.;
            vendorSha256 =
              "sha256-185Wz9IpJRBmunl+KGj/iy37YeszbT3UYzyk9V994oQ=";
            subPackages = [ "." ];

            meta = with lib; {
              description = "TODO";
              homepage = "https://github.com/pinpox/matrix-hook";
              license = licenses.gpl3;
              maintainers = with maintainers; [ pinpox ];
              platforms = platforms.linux;
            };
          };

          mock-hook = pkgs.writeScriptBin "mock-hook" ''
            #!${pkgs.stdenv.shell}
            ${curl}/bin/curl -X POST -d @mock.json http://localhost:9088/alert
          '';
        };

        defaultPackage = packages.matrix-hook;
      });
}
