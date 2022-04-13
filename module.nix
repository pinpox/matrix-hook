{ hook-package }: { config, pkgs, lib, ...}: with lib;




  # some.options = somepackage:




  # with lib;
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
        ExecStart = "${hook-package}/bin/matrix-hook";
        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

  };
}
