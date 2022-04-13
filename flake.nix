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
      overlays.default = final: prev: { matrix-hook-package = self.defaultPackage; };

      nixosModules = {
        matrix-hook =

          { lib, pkgs, config, ... }:
          with lib;
          let cfg = config.pinpox.services.matrix-hook;
          in {

            options.pinpox.services.matrix-hook = {
              enable = mkEnableOption "matrix-hook service";

              httpAddress = mkOption {
                type = types.str;
                default = "localhost";
                example = "127.0.0.1";
                description = "Host to listen on";
              };

              httpPort = mkOption {
                type = types.str;
                default = "11000";
                example = "1300";
                description = "Port to listen on";
              };

              matrixHomeserver = mkOption {
                type = types.str;
                default = "matrix.org";
                example = "mymatrix.org";
                description = "Matrix homeserver address";
              };

              matrixUser = mkOption {
                type = types.str;
                default = null;
                example = "@mr_panic:matrix.org";
                description = "Matrix user";
              };

              matrixRoom = mkOption {
                type = types.str;
                default = null;
                example = "!ilXTTTTTTuDmsz:matrix.org";
                description = "Matrix room ID";
              };

              msgTemplatePath = mkOption {
                type = types.str;
                default = null;
                example = "Path to the template to use when rendireng message";
                description = "/var/lib/tmpl";
              };

              envFile = mkOption {
                type = types.str;
                default = null;
                example = "/var/secrets/matrix-hook/envfile";
                description = ''
                  Additional environment file to pass to the service.
                  e.g. containing the long-lived access token as:
                  MX_TOKEN="LONG_LIVED_ACCESS_TOKEN"
                '';
              };
            };

            config = mkIf cfg.enable {

              nixpkgs.overlays = [ self.overlays.default ];

              # User and group
              users.users.matrix-hook = {
                isSystemUser = true;
                description = "matrix-hooksystem user";
                extraGroups = [ "matrix-hook" ];
                group = "matrix-hook";
              };

              users.groups.matrix-hook = { name = "matrix-hook"; };

              # Service
              systemd.services.matrix-hook = {
                wantedBy = [ "multi-user.target" ];
                after = [ "network.target" ];
                description = "Startmatrix-hook";
                serviceConfig = {

                  EnvironmentFile = [ cfg.envFile ];
                  Environment = [
                    "HTTP_ADDRESS='${cfg.httpAddress}'"
                    "HTTP_PORT='${cfg.httpPort}'"
                    "MX_HOMESERVER='${cfg.matrixHomeserver}'"
                    "MX_ID='${cfg.matrixUser}'"
                    "MX_ROOMID='${cfg.matrixRoom}'"
                    "MX_MSG_TEMPLATE='${cfg.msgTemplatePath}'"
                  ];

                  User = "matrix-hook";
                  ExecStart = "${pkgs.matrix-hook-package}/bin/matrix-hook";

                  Restart = "on-failure";
                  RestartSec = "5s";
                };
              };

            };
          };
      };

    } //

    flake-utils.lib.eachDefaultSystem (system:
      let pkgs = nixpkgs.legacyPackages.${system};
      in rec {
        packages = flake-utils.lib.flattenTree rec {

          matrix-hook = pkgs.buildGoModule rec {

            pname = "matrix-hook";
            version = "1.0.0";

            src = ./.;
            vendorSha256 =
              "sha256-185Wz9IpJRBmunl+KGj/iy37YeszbT3UYzyk9V994oQ=";
            subPackages = [ "." ];
            installPhase = ''
              mkdir -p $out/bin
              cp $GOPATH/bin/matrix-hook $out/bin/matrix-hook
              cp message.html.tmpl $out/bin/message.html.tmpl
            '';

            # mkdir -p $out/bin
            # mv matrix-hook $out/bin/matrix-hook
            meta = with pkgs.lib; {
              description = "Relay prometheus alerts as matrix messages";
              homepage = "https://github.com/pinpox/matrix-hook";
              license = licenses.gpl3;
              maintainers = with maintainers; [ pinpox ];
            };
          };

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
